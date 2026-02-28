#!/usr/bin/env python3
"""bin2hex.py -- Convert a raw binary to Verilog $readmemh hex format.

Each 32-bit word is read as little-endian from the binary and written as
an 8-digit uppercase hex value, one word per line.  This matches the byte
order expected by $readmemh when the memory is word-addressed.

Usage:
    python3 bin2hex.py <input.bin> <output.hex>
"""

import struct
import sys

def bin2hex(src, dst):
    with open(src, 'rb') as f:
        data = f.read()

    # Pad to a multiple of 4 bytes.
    remainder = len(data) % 4
    if remainder:
        data += b'\x00' * (4 - remainder)

    with open(dst, 'w') as f:
        for i in range(0, len(data), 4):
            word, = struct.unpack_from('<I', data, i)
            f.write(f'{word:08X}\n')

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print(f'Usage: {sys.argv[0]} <input.bin> <output.hex>', file=sys.stderr)
        sys.exit(1)
    bin2hex(sys.argv[1], sys.argv[2])
