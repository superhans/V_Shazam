function H = landmark2hash(L,S)
% H = landmark2hash(L,S)
%  Convert a set of 4-entry landmarks <t1 f1 f2 dt> 
%  into a set of <songid time hash> triples ready to store.
%  S is a scalar songid, or one per landmark (defaults to 0)
% 2008-12-29 Dan Ellis dpwe@ee.columbia.edu

% Hash value is 20 bits: 8 bits of F1, 6 bits of delta-F, 6 bits of delta-T
% Hash value is 24 bits: 10 bits of F1, 6 bits of delta-F, 8 bits of delta-T

	if nargin < 2
	  S = 0;
	end
	if length(S) == 1
	  S = repmat(S, size(L,1), 1);
	end
	% makes S and L size compatible

	H = uint32(L(:,1)); %  H contains t1

	% Make sure F1 is 0..255, not 1..256
	F1 = rem(round(L(:,2)-1),2^10); 
	DF = round(L(:,3)-L(:,2)); % contains delta-f
	if DF < 0
	   DF = DF + 2^10; 
	end

	% DF = (DF+2^8).*double(DF<0)+DF.*double(DF>=0);

	DF = rem(DF,2^6); % okay
	DT = rem(abs(round(L(:,4))), 2^6);
	H = [S,H,uint32(F1*(2^12)+DF*(2^6)+DT)];
	% H = [song_id, t1, ]


end