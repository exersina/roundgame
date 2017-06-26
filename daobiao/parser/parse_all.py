# -*- coding: utf-8 -*-
from makescript.parse import *
import os
os.system("pwd")
code_outputpath = getenv("code_outputpath")
#data_dstpath=os.path.join(code_outputpath,"data")
data_dstpath = getenv("outputpath")
cmds = {
    0 : "parse all",
    1 : "python parse_war.py ../xls/war.xls " + os.path.join(code_outputpath,"war"),
}

def show_menu():
    for choice in sorted(cmds):
        print choice,":",cmds[choice]

def main():
    while True:
        show_menu()
        choice = raw_input("enter choice(q to quit):")
        print "choice:",choice
        if choice == "q":
            break
        elif choice.isdigit():
            choice = int(choice)
            if choice == 0:
                for i,cmd in cmds.iteritems():
                    if i != 0:
                        os.system(cmd)
            elif cmds.get(choice):
                os.system(cmds[choice])

if __name__ == "__main__":
    main()
