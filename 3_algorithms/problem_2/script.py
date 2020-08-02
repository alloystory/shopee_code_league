import time

def solver():
    T = int(input())
    for i in range(T):
        S, N = [int(i) for i in input().split()]
        prices = [int(i) for i in input().split()]
        sorted_prices = sorted(prices)
        
        cost = 0
        for j in range(round(N/2)):
            cost += sorted_prices[j]
        
        print("Case {}: {}".format(i + 1, cost))
        
if __name__ == "__main__":
    start_time = time.time()
    solver()
    print("Completed in: {:.4f}s".format(time.time() - start_time))