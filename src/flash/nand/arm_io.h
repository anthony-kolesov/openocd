/*
 * Copyright (C) 2009 by David Brownell
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the
 * Free Software Foundation, Inc.,
 * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */
#ifndef __ARM_NANDIO_H
#define __ARM_NANDIO_H

/**
 * Available operational states the arm_nand_data struct can be in.
 */
enum arm_nand_op {
	ARM_NAND_NONE,	/**< No operation performed. */
	ARM_NAND_READ,	/**< Read operation performed. */
	ARM_NAND_WRITE,	/**< Write operation performed. */
};

/**
 * The arm_nand_data struct is used for defining NAND I/O operations on an ARM
 * core.
 */
struct arm_nand_data {
	/** Target is proxy for some ARM core. */
	struct target *target;

	/** The copy area holds code loop and data for I/O operations. */
	struct working_area *copy_area;

	/** The chunk size is the page size or ECC chunk. */
	unsigned chunk_size;

	/** Where data is read from or written to. */
	uint32_t data;

	/** Last operation executed using this struct. */
	enum arm_nand_op op;

	/* currently implicit:  data width == 8 bits (not 16) */
};

int arm_nandwrite(struct arm_nand_data *nand, uint8_t *data, int size);
int arm_nandread(struct arm_nand_data *nand, uint8_t *data, uint32_t size);

#endif	/* __ARM_NANDIO_H */
