# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


def is_pal(x):
    # 4-bit palindrome check: abba
    b0 = (x >> 0) & 1
    b1 = (x >> 1) & 1
    b2 = (x >> 2) & 1
    b3 = (x >> 3) & 1
    return (b3 == b0) and (b2 == b1)


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Clock: 10us period (100 kHz)
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # -------------------------
    # Reset
    # -------------------------
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0

    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1

    await ClockCycles(dut.clk, 1)

    # -------------------------
    # Test all 4-bit inputs
    # -------------------------
    dut._log.info("Testing all inputs 0–15")

    for i in range(16):
        dut.ui_in.value = i & 0xFF
        dut.uio_in.value = 0

        await ClockCycles(dut.clk, 1)

        expected = 50 if is_pal(i) else 0
        actual = int(dut.uo_out.value)

        dut._log.info(f"ui_in={i:02b} out={actual}")

        assert actual == expected, f"Mismatch for {i}: got {actual}, expected {expected}"

    dut._log.info("All tests passed!")
