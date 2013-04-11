function [notes volume] = get_notes(frequencies,amplitudes)
 
    index = 1;
    notes = [];
    volume= [];

    for i = 1:length(frequencies)
        % Having lower resolution, lower frequencies
        % have amplitudes diluted within a larger range
        % so we suppose a magical coefficient that will
        % correct the problem
        for j = i+1:length(frequencies)
            % Verifier que cest proche dun nombre entier
            fl = frequencies(j)/frequencies(i);
            int_diff = abs(fl - round(fl));
            if (int_diff < 0.05)
                % Verifier lequel est l'harmonique de l'autre
                if (amplitudes(i) > 0.9 * amplitudes(j))
                    index = [index i];
                else
                    index = [index j];
                end
                break
            end
        end
    end

    for i = 1:length(index)
        % j = i + 1;
        % for j = i+1:length(index)-i-1
        %     if(frequencies(index(i)) ~= frequencies(index(j)) - 1)
        %         break;
        %     end
        % end
        % center = find(frequencies == max(frequencies(index(i:j))));
        % frequencies(center) = mean(frequencies(i:j));
        % % index_removal = find(i:j ~= center) + i - 1;
        % i = j;

        notes = [notes frequencies(index(i))];
        volume= [volume amplitudes(index(i))];
    end


    % Get louder
    % for i = 1:length(frequencies)
    %     % if is harmonic from previous
    %     %   ignore
    %     if (
    %     
    %     % else
    % end

    % while(note > 4)
    %     for i = -4:4
    %         if ( note + i > 1 )
    %             if ( amplitudes(note + i) > amplitudes(note))
    %                 louder = note + i
    %             end
    %         end
    %     note = round(note / 2);
    % end
end
