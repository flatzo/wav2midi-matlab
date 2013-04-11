function [stop_playing] = get_stopping_notes(played, current_amp)

    stop_playing = [];

    for i = 1:length(played)
        if (current_amp(i) < 0.05)
            stop_playing = [stop_playing played(i)];
        end
    end
end
