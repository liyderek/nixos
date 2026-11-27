// SPDX-License-Identifier: GPL-2.0-only
/* Turn the SMC's AC-online notification into a system wake event for s2idle. */
#include <linux/atomic.h>
#include <linux/device.h>
#include <linux/module.h>
#include <linux/pm_wakeup.h>
#include <linux/power_supply.h>
#include <linux/string.h>

static atomic_t ac_online = ATOMIC_INIT(-1);

static int macsmc_ac_changed(struct notifier_block *nb, unsigned long event,
			     void *data)
{
	struct power_supply *psy = data;
	union power_supply_propval online;
	int previous;

	if (event != PSY_EVENT_PROP_CHANGED ||
	    strcmp(psy->desc->name, "macsmc-ac"))
		return NOTIFY_DONE;

	if (power_supply_get_property(psy, POWER_SUPPLY_PROP_ONLINE, &online))
		return NOTIFY_DONE;

	online.intval = !!online.intval;
	previous = atomic_xchg(&ac_online, online.intval);
	if (online.intval && previous != 1 && device_may_wakeup(&psy->dev)) {
		/* A hard wake exits s2idle; the timeout lets userspace handle docking. */
		pm_wakeup_dev_event(&psy->dev, 1000, true);
		dev_info(&psy->dev, "AC connected: requesting system wake\n");
	}

	return NOTIFY_OK;
}

static struct notifier_block macsmc_ac_notifier = {
	.notifier_call = macsmc_ac_changed,
};

static int __init macsmc_ac_wake_init(void)
{
	struct power_supply *psy;
	union power_supply_propval online;

	/* Seed the current state before subscribing to subsequent changes. */
	psy = power_supply_get_by_name("macsmc-ac");
	if (psy) {
		if (!power_supply_get_property(psy, POWER_SUPPLY_PROP_ONLINE, &online))
			atomic_set(&ac_online, !!online.intval);
		power_supply_put(psy);
	}

	return power_supply_reg_notifier(&macsmc_ac_notifier);
}

static void __exit macsmc_ac_wake_exit(void)
{
	power_supply_unreg_notifier(&macsmc_ac_notifier);
}

module_init(macsmc_ac_wake_init);
module_exit(macsmc_ac_wake_exit);

MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("Wake an Apple Silicon laptop on an AC power connection");
