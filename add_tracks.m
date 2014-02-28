function [N,T] = add_tracks(video_path, every_nth_frame, track_ID)
	% similar to Dan Ellis implementation. We need a waveform, a sampling rate
	% and a track_id

	H = landmark2hash(find_landmarks(video_path, every_nth_frame, track_ID),track_ID);
 	record_hashes(H);
 	N = length(H);

 	% T = total number of seconds of track added
 	% its a bit messy to compute T, so we'll skip it for now, although it is very
 	% much possible to compute T

	[a,T] = system(['ffmpeg -i ',video_path,' 2>&1 | grep "Duration"| cut -d '' '' -f 4 | sed s/,// | sed ''s@\..*@@g'' | awk ''{ split($1, A, ":"); split(A[3], B, "."); print 3600*A[1] + 60*A[2] + B[1] }''']);
	disp(['Length = ',num2str(T),' No. Hashes = ',num2str(N),' Hashes per sec : = ',num2str(N*1.0/str2num(T))]);

end