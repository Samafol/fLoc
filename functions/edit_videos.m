function seq = edit_videos(seq)
% edit_videos Edit seq so that it calculates video sequence and onsets

    all_video_lengths = seq.all_video_lengths;

    % Detect the video onsets and stimuli to go from 12 to 6
    how_many_stims = size(seq.stim_names, 1);
    how_many_videos = length(find(~cellfun(@isempty, strfind(seq.stim_names(:,1), 'Video'))));
    new_how_many_videos = round(how_many_stims - how_many_videos / 2); 

    %disp(['new_how_many_videos = ', num2str(new_how_many_videos)]);
    %disp(['seq.num_runs = ', num2str(seq.num_runs)]);

    % Preallocate per-run cell containers
    new_stim_names = cell(1, seq.num_runs);
    new_stim_onsets = cell(1, seq.num_runs);
    new_task_probes = cell(1, seq.num_runs);
    new_videos_isis = cell(1, seq.num_runs);

    isi = seq.isi_dur;

    for rr = 1:seq.num_runs
        % Extract run-specific data
        stim_names = seq.stim_names(:, rr);
        stim_onsets = seq.stim_onsets(:, rr);
        task_probes = seq.task_probes(:, rr);
        old_videos_isis = isi * ones(size(task_probes));

        video_ind = find(~cellfun(@isempty, strfind(stim_names, 'Video')));

        n_complete_blocks = floor(length(video_ind) / 12);
        if n_complete_blocks == 0
            error('No complete video blocks found (need at least 12 videos)');
        end
        video_ind = video_ind(1 : n_complete_blocks * 12);  % Trim incomplete block

        % Accumulate indices and durations to keep
        all_video_ind_to_remove = [];
        all_video_ind_to_keep = [];
        all_video_length_to_keep = [];
        new_isis = [];

        for nb = 1:n_complete_blocks
            % Block indices
            block_vids = video_ind(12 * (nb - 1) + (1:12));
            queryStrings = stim_names(block_vids);
            all_times = nan(size(queryStrings));

            for k = 1:numel(queryStrings)
                rowIdx = find(matches(all_video_lengths.Filename, queryStrings{k}), 1); % Find first match
                if ~isempty(rowIdx)
                    all_times(k) = all_video_lengths.Duration_Secs(rowIdx);
                end
            end

            % Select 6 videos that sum close to 6 seconds
            targetTotal = 6; % secs
            nSelect = 6;
            fill_strategy = 'more_isi'; % 'more_videos' or 'more_isi'
            [videos, new_isi] = find_video_combination(all_times, targetTotal, nSelect, isi, fill_strategy);

            videos_to_remove = block_vids(~ismember(1:numel(block_vids), videos));
            all_video_ind_to_remove = [all_video_ind_to_remove; videos_to_remove];
            all_video_ind_to_keep = [all_video_ind_to_keep; block_vids(videos)];
            all_video_length_to_keep = [all_video_length_to_keep; all_times(videos)];
            new_isis = [new_isis; new_isi * ones(size(all_times(videos)))];

            old_videos_isis(block_vids(videos)) = new_isi * ones(size(all_times(videos)));
        end

        % Remove unused videos
        stim_names(all_video_ind_to_remove) = [];
        task_probes(all_video_ind_to_remove) = [];
        old_videos_isis(all_video_ind_to_remove) = [];

        % Update video onset times
        stim_onsets(all_video_ind_to_keep + 1) = stim_onsets(all_video_ind_to_keep) + all_video_length_to_keep + new_isis;
        stim_onsets(all_video_ind_to_remove) = [];

        % Store run-specific processed data
        new_stim_names{rr} = stim_names;
        new_stim_onsets{rr} = stim_onsets;
        new_task_probes{rr} = task_probes;
        new_videos_isis{rr} = old_videos_isis;
    end

    % Concatenate across runs
    seq.stim_names = horzcat(new_stim_names{:});
    seq.stim_onsets = horzcat(new_stim_onsets{:});
    seq.task_probes = horzcat(new_task_probes{:});
    seq.video_isis = horzcat(new_videos_isis{:});
end



%{
function seq = edit_videos(seq)
%edit_videos Edit seq so that calculates video sequence and onsets
%   Edit seq so that calculates video sequence and onsets
    all_video_lengths = seq.all_video_lengths;
    % Detect the video onsets and stimuli to go from 12 to 6
    how_many_stims = size(seq.stim_names,1);
    how_many_videos = length(find(~cellfun(@isempty, strfind(seq.stim_names(:,1), 'Video'))));
    new_how_many_videos = how_many_stims - how_many_videos/2;

    new_how_many_videos = round(new_how_many_videos); 
    disp(['new_how_many_videos = ', num2str(new_how_many_videos)]);
    disp(['seq.num_runs = ', num2str(seq.num_runs)]);
    %new_stim_names = cell(round(new_how_many_videos), round(seq.num_runs));
    new_stim_names = cell(1, seq.num_runs);
    new_stim_onsets = cell(1, seq.num_runs);
    new_task_probes = cell(1, seq.num_runs);
    new_videos_isis = cell(1, seq.num_runs);


    %new_stim_names = cell([new_how_many_videos, seq.num_runs]);
    %new_stim_onsets = double(zeros([new_how_many_videos, seq.num_runs]));
    %new_task_probes = double(zeros([new_how_many_videos, seq.num_runs]));
    isi = seq.isi_dur;
    %new_videos_isis = isi * double(ones([new_how_many_videos, seq.num_runs]));
    for rr=1:seq.num_runs
        
        stim_names = seq.stim_names(:,rr);
        stim_onsets = seq.stim_onsets(:,rr);
        task_probes = seq.task_probes(:,rr);
        old_videos_isis = isi * double(ones(size(seq.task_probes(:,rr))));
        video_ind = find(~cellfun(@isempty, strfind(stim_names, 'Video')));
        
        n_complete_blocks = floor(length(video_ind) / 12);
        if n_complete_blocks == 0
            error('No complete video blocks found (need at least 12 videos)');
        end
        video_ind = video_ind(1:n_complete_blocks * 12);  % Trim incomplete block

        % Check if it is divisible by 12, otherwise send error
        %if ~mod(length(video_ind),12) == 0
            %error('Check video names, it is not divisible by 12')
        %end
        % Per every block, count video length and select 6 that add up to 6 sec
        all_video_ind_to_remove = [];
        all_video_ind_to_keep = [];
        all_video_length_to_keep = [];
        new_isis = [];
        for nb=1:length(video_ind)/12
            % obtain video names for this block
            block_vids = video_ind(12*(nb-1)+(1:12));
            % Preallocate result vector
            queryStrings = stim_names(block_vids);
            all_times = nan(size(queryStrings));
            for k = 1:numel(queryStrings)
                rowIdx = find(matches(all_video_lengths.Filename, queryStrings(k)), 1); % Find first match
                if ~isempty(rowIdx)
                    all_times(k) = all_video_lengths.Duration_Secs(rowIdx);
                end
            end
            targetTotal = 6; %secs
            nSelect = 6; %how many videos
            % Check that the first six videos and their isi-s are below
            % the target total or not
            fill_strategy = 'more_isi'; % options: 'more_videos', 'more_isi'
            % more_videos: it can be more videos per block, but isi will always be the same
            % more_isi: it will be always 6 videos, but isi will change every block
            % Samuel, check and let us know how it looks, see if it is randomized properly
            [videos, new_isi] = find_video_combination(all_times,targetTotal, nSelect, isi, fill_strategy);
            % Create the list for this combination
            videos_to_remove = block_vids(~ismember(1:numel(block_vids), videos));
            all_video_ind_to_remove = [all_video_ind_to_remove; videos_to_remove];
            all_video_ind_to_keep = [all_video_ind_to_keep; block_vids(videos)];
            all_video_length_to_keep = [all_video_length_to_keep; all_times(videos)];
            new_isis = [new_isis; new_isi*ones(size(all_times(videos)))];
            old_videos_isis(block_vids(videos)) = new_isi*ones(size(all_times(videos)));
        end
        % Change elements per block
        stim_names(all_video_ind_to_remove) = [];
        task_probes(all_video_ind_to_remove) = [];
        old_videos_isis(all_video_ind_to_remove) = [];
        
        % Removing is not enough, now update with video length
        stim_onsets(all_video_ind_to_keep+1) = stim_onsets(all_video_ind_to_keep) + all_video_length_to_keep + new_isis;
        % Now remove the one without update
        stim_onsets(all_video_ind_to_remove) = [];
        
        % Add to the seq
        new_stim_names(:,rr) = stim_names;
        new_stim_onsets(:,rr) = stim_onsets;
        new_task_probes(:,rr) = task_probes;
        new_videos_isis(:,rr) = old_videos_isis;
    end
    seq.stim_names = horzcat(new_stim_names{:});
    seq.stim_onsets = horzcat(new_stim_onsets{:});
    seq.task_probes = horzcat(new_task_probes{:});
    seq.video_isis = horzcat(new_videos_isis{:});
    %seq.stim_names = new_stim_names;
    %seq.stim_onsets = new_stim_onsets;
    %seq.task_probes = new_task_probes;
    %seq.video_isis = new_videos_isis;
end
%}








