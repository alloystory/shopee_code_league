from random import randint
with open("test.in", "w") as f:
    f.write("50000 50000\n")
    for i in range(50000):
        if randint(0, 100) <= 65:
            f.write("PUSH {} {}\n".format(randint(1, 50000), randint(1, 50000)))
        else:
            f.write("POP\n")