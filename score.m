pkg load signal
pkg load image

Fc = 2500

% [data, sample_rate, bps] = wavread("sounds/black-dog.wav");
 [data, sample_rate, bps] = wavread("sounds/dust-in-the-wind.wav");
% [data, sample_rate, bps] = wavread("sounds/guitar-e.wav");
[b,a] = butter(2, Fc/(sample_rate / 2))


window_size = 1024 * 2;
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

fr_p1 = [];
fr_p2 = [];
notes = [];
midi  = zeros(1,6);
time_played = zeros(1,window_size/2);
for i = 2:ffts_count-1
    % When there is a maximum, tag it as a fft_note until it's value come down a
    % @threshold
    fr = [];
    amp = [];
   
    fft_note = 1;
    for j = 1:window_size / 2 -1
        % Peak is high enough, we record it
        % TODO: There won't be any peak for lower frequency, if there is a
        % lower frequency that match the harmonics and that has an higher
        % amplitude, take this one
        if ( attack(i,j) > attack(i-1,j)    &&
             attack(i,j) > attack(i+1,j)    &&
             amplitudes(i+1,j) > 0.2) 
            fr = [fr j];
            amp = [amp amplitudes(i+1,j)];
            % if (amplitudes(i+1,j) > amplitudes(i+1,fft_note) )
            %     fft_note = j;
            %     % if real note is lower frequency, take it instead
            %     fft_note = louder_harmonic(fft_note, amplitudes(i,:));
            % end
        end
    end
  
    if (length(fr) > 0)
        t = i * (window_size ) / sample_rate;
        s_8 = round((t - floor(t)) * 8) / 8;
        t = floor(t) + s_8;


        new_notes       = get_notes(fr,amp);
        prev_n       = 0;
        for k = 1:length(new_notes)
            f = new_notes(k) * sample_rate / (window_size * 2**5);
            n = round(note(f)) + 57;       % C4 being 60

            % if( n == prev_n )
            %     continue
            % end
            if(time_played(n) == 0)
                time_played(n) = t;
            end
            prev_n = n;
        end
        stopping_notes  = setdiff(notes,new_notes);
        notes = unique([notes new_notes]);
        current_amp = [];
        for k = 1:length(notes)
            % if k ~= length(notes)
            % l = 0;
            % for l = k+1:length(notes)-k
            %     if(notes(k) ~= notes(l) - 1)
            %         break;
            %     end
            % end
            % center = find(notes == max(notes(k:l)))
            % k = l; 
            % end
            current_amp = [current_amp amplitudes(i+1,notes(k))];
        end
        stopping_notes = [stopping_notes get_stopping_notes(notes,current_amp)];

        notes = setdiff(notes,stopping_notes);
        % for k = 1:length(stopping_notes)
        %   notes = notes(find(notes ~= stopping_notes(k)))
        % end

        % v = round(amplitudes(i+1,fft_note) * 120);
        % f = fft_note * sample_rate / (window_size * 2**5);
        % t = i * (window_size ) / sample_rate;
        % s_8 = round((t - floor(t)) * 8) / 8;
        % t = floor(t) + s_8;
        % n = note(f) + 57;       % C4 being 60

        prev_n = 0;
        for k = 1:length(stopping_notes)

            fft_note = stopping_notes(k);

            v = round(amplitudes(i+1,fft_note) * 30) + 80; % * 120);
            f = fft_note * sample_rate / (window_size * 2**5);
            n = round(note(f)) + 57;       % C4 being 60
            t_0 = time_played(n);
            if(t_0 == 0)
                continue;
            end
            time_played(n) = 0;

             if(n == prev_n)
                 continue
             end
            prev_n = n;

            c_midi = zeros(1,6);
            c_midi(1,1) = 1;
            c_midi(1,2) = 1;
            c_midi(1,3) = n;
            c_midi(1,4) = v;
            c_midi(1,5) = t_0 * 1.1;
            c_midi(1,6) = t   * 1.1;

            midi = [midi; c_midi];
            fprintf('# %d : %f Hz at %fs volume: %f\n', n, f, t , v);
        end


        % harmonics = (fr(find(fr~=fft_note))) .* sample_rate ./ window_size;
    end
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
