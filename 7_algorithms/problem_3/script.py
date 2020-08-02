import time

def solver():
    Q, N = [int(i) for i in input().split()]
    components = []
    history_stack = []

    for i in range(N):
        components.append([i])

    history_stack.append(components.copy())
    for i in range(Q):
        query = input().split()
        if query[0] == "PUSH":
            switch_one = int(query[1]) - 1
            switch_two = int(query[2]) - 1
            index_s_one = -1
            index_s_two = -1
            for idx, component in enumerate(components):
                if switch_one in component:
                    index_s_one = idx
                if switch_two in component:
                    index_s_two = idx
            if index_s_one != index_s_two:
                component_one = components.pop(index_s_one)
                component_two = components.pop(index_s_two - 1) if index_s_one < index_s_two else components.pop(index_s_two)
                merged_component = component_one + component_two
                components.append(merged_component)

            components = components.copy()
            history_stack.append(components.copy())
        elif query[0] == "POP":
            history_stack.pop()
            components = history_stack[len(history_stack) - 1]
        
        print(len(components))
if __name__ == "__main__":
    start_time = time.time()
    solver()
    print("Completed in: {:.4f}s".format(time.time() - start_time))