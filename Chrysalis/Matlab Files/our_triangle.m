function t = our_triangle(H, bins)
%     The technique was initially described in Zack GW, Rogers WE, Latt SA (1977), 
%     "Automatic measurement of sister chromatid exchange frequency", 
%     J. Histochem. Cytochem. 25 (7): 741–53

% Find the maximum
[Hm, m] = max(H);

% Find the 'black'
z = length(H)-find(cumsum(fliplr(H))>0,1)+1;
Hz = H(z);

% All possible X
X = m:z;

% Find the maximal distance to the line connecting white and black
theta = atan((Hm-Hz)/(z-m));
F = (Hm-Hz)/(m-z)*(X-z)+Hz;
D = (F-H(X))*sin(theta);
[~, Dmi] = max(D);

ti = round(Dmi + (z-m)*.2)+m;
ti = min(max(ti,m),z);

t = bins(ti);

