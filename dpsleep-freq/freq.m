function mtl2(read_dir, out_dir,ext_mode)

% Check if the path is properly formatted
if ~ endsWith(read_dir, '/')
    read_dir = strcat(read_dir, '/');
end

% Check if the path is properly formatted
if ~ endsWith(out_dir, '/')
    out_dir = strcat(out_dir, '/');
end

% Get the files from directory
files = dir(strcat(read_dir, '*.mat'));  % Input
outs = dir(strcat(out_dir, '*.mat'));    % Output if they exist
d4=extractfield(files,'name');
d5=split(d4,'.'); d61=d5(:,:,1);
d51=split(d61,'_'); d6=d51(:,:,2);
filesd=datenum(d6, 'yyyy-mm-dd');  % Existing input files dates
% Find the last date of the existing output
if isempty(outs)
    outsd=[];
else
    d4=extractfield(outs,'name');
    d5=split(d4,'.'); d61=d5(:,:,1);
    d51=split(d61,'_'); d6=d51(:,:,2);
    outsd=datenum(d6,'yyyy-mm-dd');
end

%% Choose files based on the extraction mode
if ext_mode=='new'
    if isempty(outsd)
        files1=files;
    else
        files1=files(filesd>(max(outsd)-2))
    end
    if length(files1)<3
        files1=[];
        display('No new files.');
    end
elseif ext_mode=='all'
    files1=files;
end
files_len = length(files1);

% Exit if there are no files to read
if files_len == 0
    display('Files do not exist under this directory.');
    exit(1);
end

%% Loop over the time files to calculate the frequency response
for i=1:files_len
    file_path = strcat(files1(i).folder, '/', files1(i).name);
    file_name = erase(files1(i).name, '.mat');
    match = regexp(file_name,'^mtl1_(?<year>\d+)-(?<month>\d+)-(?<day>\d+)$', 'names');

    % Skip unmatched file
    if length(match) == 0
        display(replace('File %s is not supported', '%s', file_path))
        continue;
    end

    year = str2num(match.year); month = str2num(match.month); day = str2num(match.day);

    % Try reading in the file
    try
        load(file_path);
        dys = datenum(year, month, day);
        ttt = dys + [1:1:60*24]/60/24;
        dt2_len = length(dt2);

        % Find the first NaN frequency
        [m, fs_index] = max(~isnan(fs), [], 1);
        fs_value = fs(fs_index + (0:size(fs,2)-1)*size(fs,1));

        % Initialization
        axyz_all=[]; bt_all=[]; px_all=[];  py_all=[];  pz_all=[]; btm_all=[]; f_all=[]; sd_all=[]; light_all=[];
        row_from = 1; row_increment = fs_value*60*60; row_to = (row_from - 1) + row_increment;

        for hour=1:24
            % Zero array
            axyz=zeros(row_increment, 3);
            light=zeros(row_increment,1);
            bt=zeros(row_increment, 1);

            % Data extraction
            axyz(1:row_increment,1:3) = dt2(row_from:row_to,1:3);
            bt(1:row_increment,1)=dt2(row_from:row_to,5);
            light(1:row_increment,1)=dt2(row_from:row_to,4);

            % Data aggregation
            axyz_all=[axyz_all;axyz];
            %bt_all=[bt_all;bt];
            sd_all=[sd_all;ones(row_increment,1)*std(axyz,'omitnan')];
            light_all=[light_all;light];

            minute_row_from = 1; minute_row_increment = fs_value*60; 
            minute_row_to = (minute_row_from - 1) + minute_row_increment;
            axyz_len = length(axyz);
            
            % periodogram
            for minute=1:60
                [pxx,f] = pwelch(axyz(minute_row_from:minute_row_to, 1),256,0,1024,fs_value);
                [pyy,f] = pwelch(axyz(minute_row_from:minute_row_to, 2),256,0,1024,fs_value);
                [pzz,f] = pwelch(axyz(minute_row_from:minute_row_to, 3),256,0,1024,fs_value);

                % The number of nonzero elements in button
                btm_all=[btm_all;nnz(bt(minute_row_from:minute_row_to, 1))];
                pxx1=pxx((f>=0)&(f<25)); pyy1=pyy((f>=0)&(f<25)); pzz1=pzz((f>=0)&(f<25));
                px_all=[px_all;pxx1']; py_all=[py_all;pyy1']; pz_all=[pz_all;pzz1'];
                f1=f((f>=0)&(f<25)); f_all=[f_all;f1'];

                % Loop increment 
                minute_row_from = minute_row_to + 1; 
                minute_row_to = (minute_row_from - 1) + minute_row_increment;
                %if minute_row_to > axyz_len
                %    minute_row_to = axyz_len;
                %    minute_row_increment = minute_row_to - minute_row_from + 1;
                %end
            end

            % Loop increment 
            row_from = row_to + 1; row_to = (row_from - 1) + row_increment;
            if row_to > dt2_len
                row_to = dt2_len;
                row_increment = row_to - row_from + 1;
            end
        end
    catch ME
        display(ME);
        display(ME.stack);
        display('Error occured while reading in file.');
        continue;
    end

    output_name = strcat('mtl2_',match.year,'-',match.month,'-',match.day);
    if isempty(strfind(out_dir, 'data/sbdp/PHOENIX'))
        output_path = strcat(out_dir, output_name, '.mat');
    else
        output_path = strcat(out_dir, output_name, '.mat');
    end
    display(replace('Saving %s', '%s', output_path));
    save(output_path,'axyz_all','dys','px_all','py_all','pz_all','f_all','ttt','sd_all','btm_all', 'light_all');
end
display('COMPLETE');
exit(0);
