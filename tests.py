bound = 100
def iterateVerbose(n, a, b, x, y):
    curr = 0
    while curr < n:
        if (x**2 + y**2 > bound):
            break

        # print(f"x{curr}, y{curr} = {x}, {y}")
        newx = x**2 - y**2 + a
        newy = 2*x*y + b
        x = newx
        y = newy
        curr += 1
        
    return curr

w = 512
h = 256
l = -2.5
r = 2.5
b = -1.25
t = 1.25

def pixel2ComplexInWindow(col, row):
    x = (col/w)*(r - l) + l
    y = (row/h)*(t - b) + b
    return x, y

def pixel2ComplexInWindowASM(col, row):
    f4 = col
    f5 = row
    f6 = w
    f7 = h

    f8 = l
    f9 = r
    f10 = b
    f11 = t

    f12 = f4/f6
    f13 = f9-f8
    f0 = f12 * f13
    f0 = f0 + f8

    f12 = f5/f7
    f13 = f11 - f10
    f1 = f12 * f13
    f1 = f1 + f10

    return f0, f1

import cmath
from random import random
points = []
complexes = []
def reverseJulia(a, b):
    x, y = 0, 0
    for _ in range(10000):
        newx = (x - a)
        newy = y - b
        s = cmath.sqrt(newx - eval(str(newy) + "j"))
        x = s.real
        y = float(str(s.imag)[:-1])

        if random() < .5:
            x *= -1
            y *= -1

        col, row = plotComplex(x, y)
        points.append((round(row), round(col)))
        complexes.append(f"{x} + {y}i\n")

    with open("image6.txt", "w+") as f:
        for row in range(256):
            for col in range(512):
                if (row, col) in points:
                    f.write("o ")
                else:
                    f.write("  ")
            f.write("\n")

    with open("points.txt", "w+") as f:
        f.writelines([str(p) + "\n" for p in points])

    with open("complexes.txt", "w+") as f:
        f.writelines(complexes)

def plotComplex(x, y):
    col = ((w) * (x - l))/(r - l)
    row = ((h) * (y - b))/(t - b)

    return col, row


def comparePoints():
    p1 = []
    p2 = []
    with open("points.txt", "r") as f:
        p1 = [l.strip().rstrip(" i").split(" + ") for l in f.readlines()]
        p1 = [(round(float(p[0]), 2), round(float(p[1]), 2)) for p in p1]
    
    with open("points.txt", "r") as f:
        p2 = [l.strip().rstrip(" i").split(" + ") for l in f.readlines()]
        p2 = [(round(float(p[0]), 2), round(float(p[1]), 2)) for p in p2]

    with open("p1.txt", "w+") as o:
        [o.write(str(i) + "\n") for i in p1]
    with open("p2.txt", "w+") as o:
        [o.write(str(i) + "\n") for i in p2]

    count = 0
    for p in p2[:10000]:
        if p in p1:
            count += 1
    
    return str(count/100) + "%"
    
# print (pixel2ComplexInWindow(264, 19))
# print (pixel2ComplexInWindow(6, 228))

# iterateVerbose(10, 0, 0.7, *p)
# print()
# iterateVerbose(10, 0, 0.7, *o)
# iterateVerbose(30, 0, 0.7, 0.078125, -1.0644531)
# iterateVerbose(30, 0, 0.7, 0.068359375, -1.064453125)
# iterateVerbose(30, 0, 0.7, *pixel2ComplexInWindow(, 19))

# reverseJulia(0, 0.8)

# with open("image4.txt", "w+") as f:
#     for row in range(256):
#         for col in range(512):
#             iter = iterateVerbose(16, 0, 0.7, *pixel2ComplexInWindowASM(col, row))
#             if iter < 16:
#                 f.write("x ")
#             else:
#                 f.write("  ")
#         f.write("\n")


reverseJulia(0, 0)
# print(comparePoints())