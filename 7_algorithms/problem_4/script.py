import time

stocks = []
fixed_stock_items = set()
child_adj_list = []
parent_adj_list = []

def adjust_stocks(item_num, S):
    for parent in parent_adj_list[item_num]:
        parent_idx, qty = parent
        if parent_idx in fixed_stock_items:
            stocks[parent_idx] -= qty * S
            return parent_idx
        else:
            return adjust_stocks(parent_idx, qty * S)

def adjust_dynamic_stocks(parent_idx):
    for child in child_adj_list[parent_idx]:
        child_idx, qty = child
        if child_idx not in fixed_stock_items:
            stocks[child_idx] = stocks[parent_idx] // qty 
            return adjust_dynamic_stocks(child_idx)

def solver():
    N, M = [int(i) for i in input().split()]
    for i in range(N):
        stocks.append(0)
        child_adj_list.append([])
        parent_adj_list.append([])

    stocks[0] = M
    fixed_stock_items.add(0)

    for item_num in range(1, N):
        x = input()
        if x[0] == "1":
            P, Qty = [int(i) for i in x[1:].split()]
            parent_adj_list[item_num].append((P - 1, Qty))
            child_adj_list[P - 1].append((item_num, Qty))
            stocks[item_num] = stocks[P - 1] // Qty
        elif x[0] == "2":
            P, Qty, S = [int(i) for i in x[1:].split()]
            parent_adj_list[item_num].append((P - 1, Qty))
            child_adj_list[P - 1].append((item_num, Qty))
            fixed_stock_items.add(item_num)
            stocks[item_num] = S
            parent_idx = adjust_stocks(item_num, S)
            adjust_dynamic_stocks(parent_idx)
            
    for val in stocks:
        print(val)


if __name__ == "__main__":
    start_time = time.time()
    solver()
    print(child_adj_list)
    print(parent_adj_list)
    print("Completed in: {:.4f}s".format(time.time() - start_time))