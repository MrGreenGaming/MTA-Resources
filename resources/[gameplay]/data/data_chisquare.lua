-- Calculate the inverse chi square statistic
-- Usage:
-- statistic = AchiSq(alpha,df)

function AChiSq(p,n)
	local v = 0.5
	local dv = 0.5
	local x = 0
	while dv > (1 * math.pow(10,(0 - 12))) do
		x = 1/v - 1
		dv = dv / 2
		if (ChiSq(x,n) > p) then
			v = v - dv
		else
			v = v + dv
		end
	end
	return x
end

function Norm(z) -- werkt
	local q = z * z
	if math.abs(z) > 7 then
		return (1 - 1/q + 3/(q*q))*math.exp((-q)/2)/(math.abs(z)*math.sqrt((math.pi/2)))
	else
		return ChiSq(q,1)
	end
end

function ChiSq(x,n)
	if x > 1000 or n > 1000 then
		q = Norm((math.pow(x/n,1/3) + 2/(9*n) - 1) / math.sqrt(2/(9*n)))/2
		if x > n then
			return q
		else
			return 1 - q
		end
	end
	
	local p = math.exp((-0.5)*x)
	if not isEven(n) then p = p * math.sqrt((2*x)/math.pi) end
	
	local k = n
	while k >= 2 do
		p = (p*x)/k
		k = k-2
	end
	local t = p
	local a = n
	while t > (1 * math.pow(10,0 - 15) * p) do
		a = a + 2
		t = (t*x)/a
		p = p + t
	end
	return 1-p
end

function isEven(xx)
	local x = xx / 2
	local up = math.ceil(x)
	local down = math.floor(x)
	if up == down then
		return true
	else
		return false
	end
end