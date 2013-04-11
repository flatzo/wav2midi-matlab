pkg load signal

Fc = 2500

[data, sample_rate, bps] = wavread("sounds/black-dog.wav");
% [data, sample_rate, bps] = wavread("sounds/guitar-e.wav");
[b,a] = butter(2, Fc/(sample_rate / 2))


% Data must be a factor of widow_size
% data = padarray(data,mod (length(data), window_size) - 307);

% Allocate vectors for containing every fft 
% FFTs =zeros(length(data) / window_size, window_size/2+1);
% 
% ffts_count = 0
% for i = 1:window_size:length(data)- mod(length(data), window_size)
% 	y = data(i:i+window_size-1);
% 	Y = mfft(y,msize,nyq_freq,moffset);
%     % Y = Y .* Y;
%     Y = Y/max(Y);
% 	Y = abs(Y(1:window_size/2+1));
% 	%Y = sgolayfilt(Y,3);
% 	FFTs((i-1)/window_size + 1, :) = Y;
%     ffts_count = ffts_count + 1;
% end
% 
window_size = 1024;
FFTs = mr_fft(data,window_size);
ffts_count = length(FFTs(:,1));
f = sample_rate/2*linspace(0,1,window_size/2+1);
% figure(1)
amplitudes   = filter(b,a,conv2(sgolay(5,9,0)(3,:),[0,0,1,0,0],FFTs(:,:)));

% figure(2)
% surf(conv2(sgolay(5,9,1)(3,:),[0,0,1,0,0],FFTs(:,1:60)))

% Second derivative gives the attack. The maxima seems to be timed between harmonics, which is not the case in when comparing the maxima of amplitudes for each frequencies.
% This is important, as for chord detection, I assume that each fft_note won't be played at the exact same time. Which is an approximation that could work most of the times. It is this way, easier to see which harmonic belongs to which fundamental frequency.
% The first minimum gives approximatly the moment when fft_note is stroke as it 
% A better way to find it might be to look for a new maximum, followed by a greater minimu (might be almost equal). The not has been played in between those 2 peaks as maximum represents the 
% This might not work with some instruments (mostly electronic ones, violin ... ) which gain volume with time, as a fade in sound. In this technique, we'll just assume we don't have to deal with those. 
% TODO: Add another way to detect chords as this is not really reliable. It might however, increase accuracy. 
%
% figure(3)
attack      = filter(b,a,conv2(sgolay(5,9,2)(3,:),[0,0,1,0,0],FFTs(:,:)));
% surf(attack)

fr_p1 = []
fr_p2 = []
midi  = zeros(1,6);
for i = 2:ffts_count-1
    % When there is a maximum, tag it as a fft_note until it's value come down a
    % @threshold
    fr = [];
   
    fft_note = 1;
    for j = 1:window_size / 2 -1
        % Peak is high enough, we record it
        % TODO: There won't be any peak for lower frequency, if there is a
        % lower frequency that match the harmonics and that has an higher
        % amplitude, take this one
        if ( attack(i,j) > attack(i-1,j) &&
             attack(i,j) > attack(i+1,j) &&
             amplitudes(i+1,j) > 0.3) % This is a magic threshold, got a find a way to get 
            fr = [fr j];
            if (amplitudes(i+1,j) > amplitudes(i+1,fft_note) )
                fft_note = j;
            end
        end
        
        % Follow previous peaks until they "die" to know how long the fft_note is
        % played
        if ( sizeof(find(fr_p1 == j)) = 1 &&
             amplitudes(i,j) > 0.02)
           % fr = [fr j]; 
        end

        


    end
    % fft_note = max([max(fr) max(fr_p1)]);
    if (length(fr) > 1)
        v = round(amplitudes(i+1,fft_note) * 127);
        f = fft_note * sample_rate / (window_size * 2**5);
        t = i * (window_size ) / sample_rate;
        s_8 = round((t - floor(t)) * 8) / 8;
        t = floor(t) + s_8;
        n = note(f) + 57;

        c_midi = zeros(1,6);
        c_midi(1,1) = 1;
        c_midi(1,2) = 1;
        c_midi(1,3) = n;
        c_midi(1,4) = v;
        c_midi(1,5) = t;
        c_midi(1,6) = t + 0.5;

        midi = [midi; c_midi];


        fprintf('# %d : %f Hz at %fs volume: %f\n', n, f, t , v);
        harmonics = (fr(find(fr~=fft_note))) .* sample_rate ./ window_size;
    end
    fr_p2 = fr_p1;
    fr_p1 = fr;
end

midi_new = matrix2midi(midi);
writemidi(midi_new, 'testout.mid');

% y = data(1:window_size) .* window;
% Y = fft(y) ;
% Y = abs(Y(1:window_size/2+1));
% f = sample_rate/2*linspace(0,1,window_size/2+1);
% 
% 
% Y2 =envelope(Y);
% Y3 = sgolayfilt(Y,3);
% 
% figure(100)
% plot(f, Y, f, Y2, f, Y3)
% 
% 
% 
% peaks =  peakdet( Y ,60,f)
% fft_note(peaks)
