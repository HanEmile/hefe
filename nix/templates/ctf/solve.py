from pwn import *

context.gdbinit="/nix/store/jhvjf5drzzqq54xghzz94h0a6wsn1fs1-pwndbg/share/pwndbg/gdbinit.py"

# exe = ELF("./a.out")

p = remote("138.199.213.51", 31335)
#p = gdb.debug(exe.path, gdbscript='''
#                break main
#                c
#              ''')

p.sendlineafter(b"> ", b"asd")

p.interactive()
