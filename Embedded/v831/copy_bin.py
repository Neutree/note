import os
import argparse

parse = argparse.ArgumentParser()
parse.add_argument("--seek", type=int, default=0, help="seek of output file")
parse.add_argument("--size", type=int, default=0, help="size to copy")
parse.add_argument("in_path", default="", help="file to copy")
parse.add_argument("out_path", default="", help="file to copy to")

args = parse.parse_args()

print(args)

with open(args.out_path, "rb+") as fw:
    fw.seek(args.seek)
    with open(args.in_path, "rb") as fr:
        if args.size > 0:
            content = fr.read(args.size)
        else:
            content = fr.read()
        fw.write(content)
        





