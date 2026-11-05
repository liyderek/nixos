function explicitlyAllows(entries, senderId) {
  return Array.isArray(entries) && entries.some((entry) =>
    typeof entry === "string" && [
      senderId,
      `user:${senderId}`,
      `discord:${senderId}`,
      `discord:user:${senderId}`,
    ].includes(entry.trim())
  );
}

// Only a real /jarvis interaction from an explicitly configured owner may bypass
// ordinary channel admission. Wildcards and name matching never grant this.
export function isOwnerPersonalJarvis({ interaction, cfg, discordConfig }) {
  const raw = interaction?.rawData;
  const senderId = interaction?.user?.id;
  return raw?.type === 2
    && raw?.data?.name === "jarvis"
    && [0, 1, 2].includes(raw.context)
    && typeof senderId === "string"
    && /^\d{1,20}$/.test(senderId)
    && explicitlyAllows(cfg?.commands?.ownerAllowFrom, senderId)
    && explicitlyAllows(cfg?.commands?.allowFrom?.discord, senderId)
    && explicitlyAllows(discordConfig?.allowFrom, senderId);
}
