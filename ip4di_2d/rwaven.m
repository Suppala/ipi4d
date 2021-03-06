function [kwn,kwnwi]=rwaven(amin,amax,num)


% amax=4;
% amin=1;


% Determine wavenumbers
lanz=4; % Number or wavenumbers from k0 to inf

ganz=int32(6*log(double((amax/amin)))); % Number of wavenumbers from 0 to k0
if nargin>2 
    ganz=num;
end


ganz=max(ganz,2);
ganz=min(ganz,4);
kwnanz=lanz+ganz; % total number of wavenumbers
kwn0=1/(2*amin); %k0 

% pre-allocate matrices
kwn=zeros(kwnanz,1);
kwnwi=zeros(kwnanz,1);



% [kwn,kwnwi]=gauleg(0,1,double(ganz));
[kwn(1:ganz), kwnwi(1:ganz)] = GaussLegendre(double(ganz),0,1);

for i=1:ganz
    kwnwi(i)=2*kwn0*kwnwi(i)*kwn(i);
    kwn(i)=kwn0*kwn(i)*kwn(i);
end


% [kwn(ganz+1:ganz+lanz),kwnwi(ganz+1:ganz+lanz)]=gaulag(lanz,0);
[kwn(ganz+1:ganz+lanz),kwnwi(ganz+1:ganz+lanz)]=GaussLaguerre(lanz,0);



for i=ganz+1:ganz+lanz
    kwnwi(i)=kwn0*kwnwi(i)*exp(kwn(i));
    kwn(i)=kwn0*(kwn(i)+1);
end





end





function [x,w]=gauleg(x1,x2,n)

x=zeros(n,1);
w=zeros(n,1);

	m=(n+1)/2;
	xm=0.5*(x2+x1);
	xl=0.5*(x2-x1);
	for i=1:m 
        z=cos(3.141592654*(i-0.25)/(n+0.5));
        z1=0;
		while (true)
			p1=1.0;
			p2=0.0;
			for j=1:n 
				p3=p2;
				p2=p1;
				p1=((2.0*j-1.0)*z*p2-(j-1.0)*p3)/j;
            end
			pp=n*(z*p1-p2)/(z*z-1.0);
			z1=z;
			z=z1-p1/pp;
            
            if (abs(z-z1) > eps); break; end
        end
           
           
           
		x(i)=xm-xl*z;
		x(n+1-i)=xm+xl*z;
		w(i)=2.0*xl/((1.0-z*z)*pp*pp);
		w(n+1-i)=w(i);
       end
       
end


    
function [x,w]=gaulag(n,alf)
MAXIT=10;
x=zeros(n,1);
w=zeros(n,1);

	for i=1:n
		if (i == 1)
			z=(1.0+alf)*(3.0+0.92*alf)/(1.0+2.4*n+1.8*alf);
        elseif (i == 2)
			z =z+ (15.0+6.25*alf)/(1.0+0.9*alf+2.5*n);
		else 
			ai=i-2;
			z =z+((1.0+2.55*ai)/(1.9*ai)+1.26*ai*alf/ ...
				(1.0+3.5*ai))*(z-x(i-2))/(1.0+0.3*alf);
        end
		for its=1:MAXIT 
			p1=1.0;
			p2=0.0;
			for j=1:n 
				p3=p2;
				p2=p1;
				p1=((2*j-1+alf-z)*p2-(j-1+alf)*p3)/j;
            end
			pp=(n*p1-(n+alf)*p2)/z;
			z1=z;
			z=z1-p1/pp;
			if (abs(z-z1) <= eps) ;break; end
        end
		if (its > MAXIT) ;disp('too many iterations in gaula'); end
		x(i)=z;
 		w(i) = -exp( gammln(alf+n)-gammln(double(n)) )/(pp*n*p2);
    end





end





function y=gammln(xx)

	
	cof=[76.18009172947146,-86.50532032941677,...
		24.01409824083091,-1.231739572450155,...
		0.1208650973866179e-2,-0.5395239384953e-5];
	

	y=xx;
    x=xx;
	tmp=x+5.5;
	tmp =tmp-(x+0.5)*log(tmp);
	ser=1.000000000190015;
	for j=1:6 
        y=y+1;
        ser =ser+cof(j)/y;
    end
	y=-tmp+log(2.5066282746310005*ser/x);
    
    
end


function [x, w] = GaussLaguerre(n, alpha)

% This function determines the abscisas (x) and weights (w) for the
% Gauss-Laguerre quadrature of order n>1, on the interval [0, +infinity].
    % Unlike the function 'GaussLaguerre', this function is valid for
    % n>=34. This is due to the fact that the companion matrix (of the n'th
    % degree Laguerre polynomial) is now constructed as a symmetrical
    % matrix, guaranteeing that all the eigenvalues (roots) will be real.
    
    
% � Geert Van Damme
% geert@vandamme-iliano.be
% February 21, 2010    



% Building the companion matrix CM
    % CM is such that det(xI-CM)=L_n(x), with L_n the Laguerree polynomial
    % under consideration. Moreover, CM will be constructed in such a way
    % that it is symmetrical.
i   = 1:n;
a   = (2*i-1) + alpha;
b   = sqrt( i(1:n-1) .* ((1:n-1) + alpha) );
CM  = diag(a) + diag(b,1) + diag(b,-1);

% Determining the abscissas (x) and weights (w)
    % - since det(xI-CM)=L_n(x), the abscissas are the roots of the
    %   characteristic polynomial, i.d. the eigenvalues of CM;
    % - the weights can be derived from the corresponding eigenvectors.
[V L]   = eig(CM);
[x ind] = sort(diag(L));
V       = V(:,ind)';
w       = gamma(alpha+1) .* V(:,1).^2;

end


function [x, w] = GaussLegendre(n,aa,bb)

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
% This function determines the abscisas (x) and weights (w)  for the        %
% Gauss-Legendre quadrature, of order n>1, on the interval [-1, +1].        %
%   Unlike many publicly available functions, 'GaussLegendre_2' is valid    %
%   for n>=46. This is due to the fact that 'GaussLegendre_2' does not      %
%   rely on the build-in Matlab routine 'roots' to determine the roots of   %
%   the Legendre polynomial, but finds the roots by looking for the         %
%   eigenvalues of an alternative version of the companion matrix of the    %
%   n'th degree Legendre polynomial. The companion matrix is constructed    %
%   as a symmetrical matrix, guaranteeing that all the eigenvalues          %
%   (roots) will be real. On the contrary, the 'roots' function uses a      %
%   general form for the companion matrix, which becomes unstable at        %
%   higher orders n, leading to complex roots.                              %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %


% � Geert Van Damme
% geert@vandamme-iliano.be
% February 21, 2010    



% Building the companion matrix CM
    % CM is such that det(xI-CM)=P_n(x), with P_n the Legendre polynomial
    % under consideration. Moreover, CM will be constructed in such a way
    % that it is symmetrical.
i   = 1:n-1;
a   = i./sqrt(4*i.^2-1);
CM  = diag(a,1) + diag(a,-1);

% Determining the abscissas (x) and weights (w)
    % - since det(xI-CM)=P_n(x), the abscissas are the roots of the
    %   characteristic polynomial, i.d. the eigenvalues of CM;
    % - the weights can be derived from the corresponding eigenvectors.
[V L]   = eig(CM);
[x ind] = sort(diag(L));
V       = V(:,ind)';
w       = 2 * V(:,1).^2;



% Linear map from[-1,1] to [aa,bb]
x=(aa*(1-x)+bb*(1+x))/2;     
w=(bb-aa).*w/2;


end



function [x,w]=lgwt(N,a,b)

% lgwt.m
%
% This script is for computing definite integrals using Legendre-Gauss 
% Quadrature. Computes the Legendre-Gauss nodes and weights  on an interval
% [a,b] with truncation order N
%
% Suppose you have a continuous function f(x) which is defined on [a,b]
% which you can evaluate at any x in [a,b]. Simply evaluate it at all of
% the values contained in the x vector to obtain a vector f. Then compute
% the definite integral using sum(f.*w);
%
% Written by Greg von Winckel - 02/25/2004
N=N-1;
N1=N+1; N2=N+2;

xu=linspace(-1,1,N1)';

% Initial guess
y=cos((2*(0:N)'+1)*pi/(2*N+2))+(0.27/N1)*sin(pi*xu*N/N2);

% Legendre-Gauss Vandermonde Matrix
L=zeros(N1,N2);

% Derivative of LGVM
Lp=zeros(N1,N2);

% Compute the zeros of the N+1 Legendre Polynomial
% using the recursion relation and the Newton-Raphson method

y0=2;

% Iterate until new points are uniformly within epsilon of old points
while max(abs(y-y0))>eps
    
    
    L(:,1)=1;
    Lp(:,1)=0;
    
    L(:,2)=y;
    Lp(:,2)=1;
    
    for k=2:N1
        L(:,k+1)=( (2*k-1)*y.*L(:,k)-(k-1)*L(:,k-1) )/k;
    end
 
    Lp=(N2)*( L(:,N1)-y.*L(:,N2) )./(1-y.^2);   
    
    y0=y;
    y=y0-L(:,N2)./Lp;
    
end

% Linear map from[-1,1] to [a,b]
x=(a*(1-y)+b*(1+y))/2;      

% Compute the weights
w=(b-a)./((1-y.^2).*Lp.^2)*(N2/N1)^2;

end
