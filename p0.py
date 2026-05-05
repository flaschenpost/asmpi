from decimal import Decimal, getcontext

# Setze die Genauigkeit auf 100 Stellen
getcontext().prec = 500

m=Decimal(925)
n=Decimal(2)
d=Decimal(1)

print(n/d)
print("m=",m," d=", d, " n=", n , " q=", (n/d))
# reziprok

while m>1:
    t = 6*n+d*m*m
    d=n
    n=t
    m=m-2
    print("m=",m," n=", n, " d=" , d)
print(" n=", n, " d=" , d, " q=", (d/n))
p=Decimal(d) / Decimal(n)
print(p)


