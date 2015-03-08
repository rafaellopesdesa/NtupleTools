import sys

def find_nth(haystack, needle, n):
    start = haystack.find(needle)
    while start >= 0 and n > 1:
        start = haystack.find(needle, start+len(needle))
        n -= 1
    return start

input = sys.argv[1]

start = find_nth(input, "/", 4)

reduced = input[start+1:]

print reduced.replace("/","_")
