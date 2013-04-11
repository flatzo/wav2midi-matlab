function [louder] = louder_harmonic(note,amplitudes)
    
    louder = note;

    while(note > 4)
        for i = -4:4
            if ( note + i > 1 )
                if ( amplitudes(note + i) > amplitudes(note))
                    louder = note + i
                end
            end
        note = round(note / 2);
    end
end
