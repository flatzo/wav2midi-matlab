pkg load signal
pkg load image

window_size = 2048 .* 2
window = hamming(window_size);
Fc = 2500

[data, sample_rate, bps] = wavread("sounds/black-dog.wav");
[b,a] = butter(2, Fc/(sample_rate / 2))

f = sample_rate/2*linspace(0,1,window_size/2+1);

% Data must be a factor of widow_size
% data = padarray(data,mod (length(data), window_size) - 307);

% Allocate vectors for containing every fft 
FFTs =zeros(length(data) / window_size, window_size/2+1);

ffts_count = 0
for i = 1:window_size:length(data)- mod(length(data), window_size)
	y = data(i:i+window_size-1) .* window;
	Y = fft(y,window_size);
    % Y = Y .* Y;
    Y = Y/max(Y);
	Y = abs(Y(1:window_size/2+1));
	%Y = sgolayfilt(Y,3);
	FFTs((i-1)/window_size + 1, :) = Y;
    ffts_count = ffts_count + 1;
end

% figure(1)
amplitudes   = filter(b,a,conv2(sgolay(5,9,0)(3,:),[0,0,1,0,0],FFTs(:,:)));

% figure(2)
% surf(conv2(sgolay(5,9,1)(3,:),[0,0,1,0,0],FFTs(:,1:60)))

% Second derivative gives the attack. The maxima seems to be timed between harmonics, which is not the case in when comparing the maxima of amplitudes for each frequencies.
% This is important, as for chord detection, I assume that each note won't be played at the exact same time. Which is an approximation that could work most of the times. It is this way, easier to see which harmonic belongs to which fundamental frequency.
% The first minimum gives approximatly the moment when note is stroke as it 
% A better way to find it might be to look for a new maximum, followed by a greater minimu (might be almost equal). The not has been played in between those 2 peaks as maximum represents the 
% This might not work with some instruments (mostly electronic ones, violin ... ) which gain volume with time, as a fade in sound. In this technique, we'll just assume we don't have to deal with those. 
% TODO: Add another way to detect chords as this is not really reliable. It might however, increase accuracy. 
%
% figure(3)
% surf(attack)
attack      = filter(b,a,conv2(sgolay(5,9,2)(3,:),[0,0,1,0,0],FFTs(:,:)));

fr_p1 = []
fr_p2 = []
for i = 2:ffts_count-1
    % When there is a maximum, tag it as a note until it's value come down a
    % @threshold
    fr = [];
   
    note = 1;
    for j = 1:window_size / 2 -1
        % Peak is high enough, we record it
        if ( attack(i,j) > attack(i-1,j) &&
             attack(i,j) > attack(i+1,j) &&
             amplitudes(i+1,j) > 0.2) % This is a magic threshold, got a find a way to get 
            fr = [fr j];
            if (amplitudes(i+1,j) > amplitudes(i+1,note) )
                note = j;
            end
        end
        
        % Follow previous peaks until they "die" to know how long the note is
        % played
        if ( sizeof(find(fr_p1 == j)) = 1 &&
             amplitudes(i,j) > 0.2)
           % fr = [fr j]; 
        end

        


    end
    % note = max([max(fr) max(fr_p1)]);
    if (length(fr) > 1)
        fprintf('# %d : %f Hz at %ds amplitude : %f\n', note, (note - 2) .* sample_rate ./ window_size, window_size ./ sample_rate .* j, amplitudes(i,note));
        harmonics = (fr(find(fr~=note)) - 2) .* sample_rate ./ window_size;
    end
    fr_p2 = fr_p1;
    fr_p1 = fr;
end


y = data(1:window_size) .* window;
Y = fft(y) ;
Y = abs(Y(1:window_size/2+1));
f = sample_rate/2*linspace(0,1,window_size/2+1);


Y2=envelope(Y);
Y3 = sgolayfilt(Y,3);

% figure(100)
% plot(f, Y, f, Y2, f, Y3)
% 
% 
% 
% peaks =  peakdet( Y ,60,f)
% note(peaks)

