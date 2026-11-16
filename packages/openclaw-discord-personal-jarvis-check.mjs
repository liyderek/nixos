import assert from "node:assert/strict";
import { pathToFileURL } from "node:url";
import { mkdir } from "node:fs/promises";

const root = process.argv[2];
const load = (path) => import(pathToFileURL(`${root}/${path}`).href);
const { isOwnerPersonalJarvis } = await load("dist/.setup/personal-jarvis.mjs");
const owner = "1353908629501247498";
const other = "123456789012345678";
const discordConfig = {
  enabled: true,
  dmPolicy: "allowlist",
  allowFrom: [owner],
  groupPolicy: "disabled",
  dm: { groupEnabled: false },
};
const cfg = {
  commands: {
    allowFrom: { discord: [`user:${owner}`] },
    ownerAllowFrom: [`discord:user:${owner}`],
  },
  channels: { discord: discordConfig },
};
const interactionFor = (context, sender = owner, name = "jarvis") => ({
  user: { id: sender, username: "test-user" },
  rawData: { type: 2, context, data: { name } },
});

for (const context of [0, 1, 2]) {
  assert.equal(isOwnerPersonalJarvis({ interaction: interactionFor(context), cfg, discordConfig }), true);
  assert.equal(isOwnerPersonalJarvis({ interaction: interactionFor(context, other), cfg, discordConfig }), false);
  assert.equal(isOwnerPersonalJarvis({ interaction: interactionFor(context, owner, "status"), cfg, discordConfig }), false);
  assert.equal(isOwnerPersonalJarvis({ interaction: interactionFor(context, owner, "ask"), cfg, discordConfig }), false);
}
for (const field of ["owners", "commands", "dms"]) {
  const changedCfg = structuredClone(cfg);
  const changedDiscord = structuredClone(discordConfig);
  if (field === "owners") changedCfg.commands.ownerAllowFrom = ["*"];
  if (field === "commands") changedCfg.commands.allowFrom.discord = ["*"];
  if (field === "dms") changedDiscord.allowFrom = ["*"];
  assert.equal(isOwnerPersonalJarvis({ interaction: interactionFor(2), cfg: changedCfg, discordConfig: changedDiscord }), false);
}
const ordinaryMessage = interactionFor(2);
ordinaryMessage.rawData.type = 0;
assert.equal(isOwnerPersonalJarvis({ interaction: ordinaryMessage, cfg, discordConfig }), false);
assert.equal(isOwnerPersonalJarvis({ interaction: interactionFor(99), cfg, discordConfig }), false);

// Exercise the installed native command handler, stopping at admitted context
// creation so no model, network request, or external message is needed.
await mkdir(process.env.HOME, { recursive: true });
const { createDiscordNativeCommand, isDiscordGroupAllowedByPolicy } = await load("dist/runtime-api.js");
const { setDiscordRuntime } = await load("dist/runtime-setter-api.js");
setDiscordRuntime({
  channel: {
    inbound: {
      ingress: {
        createResolver: () => ({
          command: async () => ({}),
          message: async ({ subject, allowFrom }) => {
            const allowed = allowFrom.includes(subject.stableId);
            return {
              senderAccess: { allowed, decision: allowed ? "allow" : "deny" },
              commandAccess: { authorized: allowed },
            };
          },
        }),
      },
    },
  },
});

let counter = 0;
async function admitted(context, sender = owner, name = "jarvis", current = true) {
  const marker = new Error("admitted test interaction");
  const replies = [];
  const deferrals = [];
  const channelId = `10000000000000${++counter}`;
  const interaction = interactionFor(context, sender, name);
  interaction.rawData.id = `20000000000000${counter}`;
  interaction.rawData.channel_id = channelId;
  interaction.channel = { id: channelId, type: context === 0 ? 0 : context === 1 ? 1 : 3, name: "test-channel" };
  interaction.guild = context === 0 ? { id: "300000000000000001", name: "test-guild" } : null;
  interaction.client = { fetchChannel: async () => null };
  interaction.options = { getString: () => "Reply with OK" };
  interaction.defer = async (options) => { deferrals.push(options); };
  interaction.followUp = async (reply) => { replies.push(reply); };
  interaction.reply = interaction.followUp;
  const command = createDiscordNativeCommand({
    command: { name, description: "Test command", acceptsArgs: true },
    cfg,
    accountId: "default",
    discordConfig,
    ephemeralDefault: false,
    sessionPrefix: "agent:main:discord:slash",
    threadBindings: { getByThreadId: () => null },
    readPolicy: async () => ({ cfg, discordConfig, isCurrent: () => current }),
    buildContext: async () => { throw marker; },
  });
  try {
    await command.run(interaction);
    return { allowed: false, replies, deferrals };
  } catch (error) {
    if (error === marker) return { allowed: true, replies, deferrals };
    throw error;
  }
}

for (const context of [0, 1, 2]) {
  const result = await admitted(context);
  assert.equal(result.allowed, true, `owner /jarvis context ${context}`);
  assert.equal(result.deferrals[0]?.ephemeral, false, `public /jarvis reply context ${context}`);
  assert.equal((await admitted(context, other)).allowed, false, `other user context ${context}`);
  assert.equal((await admitted(context, owner, "jarvis", false)).allowed, false, `stale policy context ${context}`);
}
for (const context of [0, 2]) {
  assert.equal((await admitted(context, owner, "help")).allowed, false, `other command context ${context}`);
  assert.equal((await admitted(context, owner, "ask")).allowed, false, `old /ask command context ${context}`);
}
assert.equal(isDiscordGroupAllowedByPolicy({ groupPolicy: "disabled" }), false);
console.log("Discord personal /jarvis: public replies and owner-only admission verified in guilds, DMs, and group DMs; ordinary group policy remains disabled.");
