
function [freq_data] = mr_fft(time_data,hf_window_size,sample_rate)
    band_count = 6;
    lf_window_size = hf_window_size * 2**(band_count-1) ;

    spec_length = floor((length(time_data)-lf_window_size) / hf_window_size)
    freq_count  = lf_window_size / 2
    freq_data   = zeros(spec_length-1, freq_count);
  
    % FFT on each frequency band
    % Band 1            : hi frequency
    % Band (band_count) : low_frequency
    for band = 2:band_count
        
        window_size = hf_window_size * 2**(band-1);
        window      = hanning(window_size);

        band_end    = freq_count / 2**(band)
        band_start  = band_end / 2

        % Do a FFT for every multiple of high frequency window 
        % FFT is however done on band's own window_size
        band
        for i = 1:spec_length-1
            t = i * hf_window_size - window_size / 2;
            if t < 1
                t = 1;
            end
            y = time_data(t:t+window_size-1) .* window;
            Y = fft(y,window_size);
            Y = abs(Y(1:window_size/2));
            Y = Y ./ max(Y);
            % Y = Y ./ window_size;

            length(Y);
            Y = kron(Y, ones(band_count-band+1));
            length(Y);

            freq_data(i,band_start:band_end) = Y(band_start:band_end);
        end
    end
end
