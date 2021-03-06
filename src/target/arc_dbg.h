/*
 * Copyright (C) 2012 Synopsys, Inc. (www.synopsys.com)
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 *   Maintainer: frank.dols@synopsys.com
 */

#ifndef ARC_DBG_H
#define ARC_DBG_H

/* ----- Supporting functions ---------------------------------------------- */

//printf(" >> Entering: %s(%s @ln:%d)\n",__func__,__FILE__,__LINE__);

int arc_dbg_enter_debug(struct target *target);
int arc_dbg_debug_entry(struct target *target);
int arc_dbg_exit_debug(struct target *target);

/* ----- Exported functions ------------------------------------------------ */

int arc_dbg_halt(struct target *target);
int arc_dbg_resume(struct target *target, int current, uint32_t address,
	int handle_breakpoints, int debug_execution);
int arc_dbg_step(struct target *target, int current, uint32_t address,
	int handle_breakpoints);

/* ......................................................................... */

int arc_dbg_add_breakpoint(struct target *target,
	struct breakpoint *breakpoint);
int arc_dbg_add_context_breakpoint(struct target *target,
	struct breakpoint *breakpoint);
int arc_dbg_add_hybrid_breakpoint(struct target *target,
	struct breakpoint *breakpoint);
int arc_dbg_remove_breakpoint(struct target *target,
	struct breakpoint *breakpoint);

int arc_dbg_add_watchpoint(struct target *target,
	struct watchpoint *watchpoint);
int arc_dbg_remove_watchpoint(struct target *target,
	struct watchpoint *watchpoint);

#endif /* ARC_DBG_H */
