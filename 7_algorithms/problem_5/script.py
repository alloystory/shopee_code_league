import time
import math

def solver():
    def calcDist(first, second):
        return math.ceil(math.sqrt(
            (first[0] - second[0]) ** 2 + 
            (first[1] - second[1]) ** 2
        ))

    N = int(input())
    engCoord = []
    for i in range(N):
        x, y = [int(j) for j in input().split()]
        engCoord.append((x, y))
    
    Xg, Yg, Xa, Ya = [int(j) for j in input().split()]
    engDist = []
    for coord in engCoord:
        engDist.append((calcDist(coord, (Xg, Yg)), calcDist(coord, (Xa, Ya))))
    
    Q = int(input())
    for i in range(Q):
        res = 0
        Rg, Ra = [int(j) for j in input().split()]
        for dist in engDist:
            if Rg < dist[0] and Ra < dist[1]:
                res += 1
            elif Rg >= dist[0] and Ra >= dist[1]:
                res += 1
        print(res)

if __name__ == "__main__":
    start_time = time.time()
    solver()
    print("Completed in: {:.4f}s".format(time.time() - start_time))