function J = imedgefuse( para, varargin )
global g_para;
set_parameters( para );
g_para.nImg = length( varargin ); % number of images

nImg = g_para.nImg;
nLv = g_para.nLv; % total number of decomposition

%
% Wavelet decomposition for the Y of YCbCr
%
for k = 1:nImg
	% RGB color images are converted into the YCrCb color. 
	I = my_imread( varargin{ k } );
	
	if k == 1 % initialization of the coefficient array
		[ey, ex, nLv] = output_size( size(I,1), size(I,2), nLv );
		C = zeros(ey,ex,nImg);
	end
	[C(:,:,k), S] = wavedec97( I(:,:,1),  nLv );

end

W = gen3DWeightMatrix( C, S );
F = genNewSubbands( C, W );

J(:,:,1) = waverec97( F, S );

if g_para.bColor == 0
	return
end

%
% Wavelet decomposition for the Cb of YCbCr
%

for k = 1:nImg
	I = my_imread( varargin{ k } );
	[C(:,:,k), S] = wavedec97( I(:,:,2),  nLv );
	
end

F = genNewSubbands( C, W );
J(:,:,2) = waverec97( F, S );

%
% Wavelet decomposition for the Cr of YCbCr
%

for k = 1:nImg
	I = my_imread( varargin{ k } );
	[C(:,:,k),  S] = wavedec97( I(:,:,3 ), nLv );
	
end


F = genNewSubbands( C, W );
J(:,:,3) = waverec97( F, S );

%
% Final conversion
%
J = ycbcr2rgb( J );

end

%
%--------------------------------------------------------------------------
%

function set_parameters( para )

global g_para;
g_para = para; % initialization

% total number of decompositions
if ~isfield( g_para, 'nLv' )
	g_para.nLv = 5;
end

% weight propagation among subbands from parent to children
if ~isfield( g_para, 'propagate' )
	g_para.propagate = 1;
end

% weight smoothing at each subband
if ~isfield( g_para, 'denoise' )
	g_para.denoise = 1;
end

% hide debug message
if ~isfield( g_para, 'debug_mode' )
	g_para.debug_mode = false(1);
end

g_para.bColor = true(1); % color image

end

%
%--------------------------------------------------------------------------
%

function I = my_imread( I )
if ischar( I )
	I = imread( char( I ) );
end
if size( I, 3 ) ~= 3
	g_para.bColor = false;
end
if ~isa( I, 'double' )
	I = im2double( I );
end
if size( I, 3 ) == 3
	I = rgb2ycbcr( I );
end

end

%
%--------------------------------------------------------------------------
%

function W = gen3DWeightMatrix( C, S )
%
% C : wavelet coefficient image
% S : wavelet sub-bands size
%
global g_para;


nLv = size(S, 1) - 1;

% Weight matrix
W = zeros( size(C) );

% G is low pass filter for denoising
G = fspecial( 'gaussian', 3, 3 ); % almost box filter


for iLv = nLv:-1:1
	sy = S( iLv, 1 );
	sx = S( iLv, 2 );
	
	W(   1:sy   , sx+1:sx+sx, :) = detailCoef2Weight( C(   1:sy   , sx+1:sx+sx, : ), G);
	W(sy+1:sy+sy,    1:sx   , :) = detailCoef2Weight( C(sy+1:sy+sy,    1:sx   , : ), G);
	W(sy+1:sy+sy, sx+1:sx+sx, :) = detailCoef2Weight( C(sy+1:sy+sy, sx+1:sx+sx, : ), G);

end

%
% Wavelet parents-to-child relationship
%
if ( g_para.propagate == 1 )


	for iLv = nLv-1:-1:1
		sy_p = S( iLv, 1 );    sx_p = S( iLv, 2 );
		sy_c = S( iLv+1, 1 );  sx_c = S( iLv+1, 2 );

		W(  1:sy_p, sx_p+1:sx_p+sx_p, : ) ...
			= reweightDetailSubband( ...
			  W( 1:sy_p, sx_p+1:sx_p+sx_p, : ), ...
			  W( 1:sy_c, sx_c+1:sx_c+sx_c, : ) );

		W(  sy_p+1:sy_p+sy_p,  1:sx_p, : ) ...
			= reweightDetailSubband( ...
			  W( sy_p+1:sy_p+sy_p, 1:sx_p, : ), ...
			  W( sy_c+1:sy_c+sy_c, 1:sx_c, : ) );

		W(  sy_p+1:sy_p+sy_p, sx_p+1:sx_p+sx_p, : ) ...
			= reweightDetailSubband( ...
			  W( sy_p+1:sy_p+sy_p, sx_p+1:sx_p+sx_p, : ), ...
			  W( sy_c+1:sy_c+sy_c, sx_c+1:sx_c+sx_c, : ) );

	end
end

%
% Create the weight map of the approximation coefficient sub-band 
%

sy = S(1,1);  sx = S(1,2);

W(1:sy, 1:sx, :) = reweightApproxSubband(  ...
	W(   1:sy   , sx+1:sx+sx, :),  ...
	W(sy+1:sy+sy,    1:sx   , :),  ...
	W(sy+1:sy+sy, sx+1:sx+sx, :) );


end

%
%--------------------------------------------------------------------------
%

function W = detailCoef2Weight( C, G )
%
% G is low pass filter
%
global g_para;

[~, K] = max(abs(C), [], 3);

% convert index to usage ratio	
W = zeros( size(C) );
for k = 1:size( C, 3 )
	W(:,:,k) = (K == k);
end

if ( g_para.denoise == 1 )
	W =	imfilter( W, G, 'symmetric' );
end

end

%
%--------------------------------------------------------------------------
%

function Wp = reweightDetailSubband( Wp, Wc )
%
% Deblur detail sub-bands by passing up and conversing the weight vectors
%
global g_para;
nImg = g_para.nImg;

Wc = Wc(1:2:end, :, :) + Wc(2:2:end, :, :); % ex 1 2 3 4 > 3 7
Wc = Wc(:, 1:2:end, :) + Wc(:, 1:2:end, :);
Wc = 0.25 * Wc;

Wp = Wp .* Wc;
W_sum = sum( Wp,  3 );
Mask  = W_sum ~= 0;
W_sum = W_sum + ~Mask; % interpolate 1 to avoid showing 'divide by 0'

W_sum = repmat( W_sum, [1,1,nImg] );
Mask = repmat( Mask, [1,1,nImg] );

Wp = Mask .* ( Wp ./ W_sum ) + ~Mask .* Wc;

end

%
%--------------------------------------------------------------------------
%

function Wa = reweightApproxSubband( Wh, Wv, Wd )
%
% Deblur the approximation sub-band by passing up
% and conversing the weight vectors
%
Wa = (1/3) * (Wh + Wv + Wd);

end

%
%--------------------------------------------------------------------------
%

function F = genNewSubbands( C, W )
%
% Make new sub-bands filled up with focused coefficient  
%
F = sum(C.*W, 3);

end

%
%--------------------------------------------------------------------------
%
%   Funcionts for wavelet transform
%
%--------------------------------------------------------------------------
%

function [ey, ex, n] = output_size( sy, sx, n )
	n_max = floor( log2( min(sy,sx) ) ) - 1;
	if (n > n_max)
		n = n_max;
	end
	n2 = 2^n;

	% Extend image symmetrically
	ey = n2 * floor( ( sy-1 )/n2 ) + n2;
	ex = n2 * floor( ( sx-1 )/n2 ) + n2;
end

%
%--------------------------------------------------------------------------
%

function [C, S] = wavedec97(A, n)
[sy,sx] = size( A );
[ey,ex,n] = output_size( sy, sx, n );

% image padding
dy = ey - sy;
dx = ex - sx;
pady = 1:sy;
padx = 1:sx;
if ( dy > 0 ) pady = [pady, fliplr( pady( end-dy:end-1 ) )]; end
if ( dx > 0 ) padx = [padx, fliplr( padx( end-dx:end-1 ) )]; end
if ( dy > 0 || dx > 0 )
	A = A( pady, padx );
end

% Initialize output arguments
C = zeros(ey,ex);
S = [sy,sx];

% Aterative decomposition
for iL = 1:n
	[A, H, V, D] = dwt97( A );

 	hy = ey * 0.5;
	hx = ex * 0.5;
	C(1:hy,    hx+1:ex) = H;
	C(hy+1:ey, 1:hx   ) = V;
	C(hy+1:ey, hx+1:ex) = D;

	S = [hy,hx; S];
	ey = hy;  ex = hx;
end
C( 1:hy,  1:hx ) = A;

end

%
%--------------------------------------------------------------------------
%

function [A, H, V, D] = dwt97( A )

l = [-1.58613432, -0.05298011854, 0.8829110762, 0.4435068522;
	 -1.58613432, -0.05298011854, 0.8829110762, 0.4435068522];
s = 1.149604398; % scale factor

[L, H] = filterdownl( A,  l, s );
[V, D] = filterdownl( H', l, s );    D = D';    V = V';
[A, H] = filterdownl( L', l, s );    H = H';    A = A';

end

%
%--------------------------------------------------------------------------
%

function [A, D] = filterdownl( X, l, s )

[sy2, sx] = size( X );
sy = 0.5*sy2;

A = X(1:2:end,:);
D = X(2:2:end,:);

pado = [1:sy, sy];
pade = [1, 1:sy];

D = D + filter2( l(:,1),  A(pado,:),  'valid' );
A = A + filter2( l(:,2),  D(pade,:),  'valid' );
D = D + filter2( l(:,3),  A(pado,:),  'valid' );
A = A + filter2( l(:,4),  D(pade,:),  'valid' );

A = A * s;
D = D *(1/s);

end

%
%--------------------------------------------------------------------------
%

function A = waverec97( C, S )

N = length( S )-1;
A = C( 1:S(1,1),  1:S(1,2) );

for i = 1:N
	sy = S(i,1);
	sx = S(i,2);
	sy2 = sy + sy;
	sx2 = sx + sx;

	H = C(    1:sy , sx+1:sx2 );
	V = C( sy+1:sy2,    1:sx  );
	D = C( sy+1:sy2, sx+1:sx2 );

	A = idwt97( A,  H,  V,  D );
end

A = A( 1:S( N+1, 1 ), 1:S( N+1, 2 ) );

end

%
%--------------------------------------------------------------------------
%

function A = idwt97( A, H, V, D )

l = [-1.58613432, -0.05298011854, 0.8829110762, 0.4435068522;
	 -1.58613432, -0.05298011854, 0.8829110762, 0.4435068522];
s = 1.149604398;

L = filterupl( A', H', l, s )';
H = filterupl( V', D', l, s )';
A = filterupl( L,  H,  l, s );
end

%
%--------------------------------------------------------------------------
%

function X = filterupl( A, D, l, s )
[sy,sx] = size( A );
sy2 = sy * 2;

pado = [1:sy, sy];
pade = [1, 1:sy];

D = s * D;
A = (1/s) * A;

A = A - filter2( l(:,4), D(pade,:), 'valid' );
D = D - filter2( l(:,3), A(pado,:), 'valid' );
A = A - filter2( l(:,2), D(pade,:), 'valid' );
D = D - filter2( l(:,1), A(pado,:), 'valid' );
X( [1:2:sy2, 2:2:sy2], : ) = [A; D];

end

%
%--------------------------------------------------------------------------
%

function DEBUG_MSG( format, varargin )
%
% show message when debug mode
%
global g_para;

if g_para.debug_mode
	fprintf( format, varargin{:} );
end

end






