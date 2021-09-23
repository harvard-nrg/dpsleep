function extract(read_dir)

% Check if the path is properly formatted
if ~ endsWith(read_dir, '/')
    read_dir = strcat(read_dir, '/');
end

% Get the files from directory
files = dir(strcat(read_dir, '*.csv'));
files_len = length(files);

% Exit if there are no files to read
if files_len == 0
    display('Files do not exist under this directory.');
    exit(1);
end

% For every csv file under the directory, create a .mat file
for i=1:files_len
    file_path = strcat(files(i).folder, '/', files(i).name);
    file_name = erase(files(i).name, '.csv');

    % Try reading in the file
    try
        % Skipping the csv header and timestamp column
        dt = csvread(file_path, 1, 1);
        dt2 = dt(:, 1:end-1);
        fs = dt(:, end);
    catch ME
        display(ME);
        display(ME.stack);
        display('Error occured while reading in file.');
        continue;
    end

    % Check if the file is empty
    if isempty(dt2)
        display('File is empty');
        continue;
    end
    
    output_path = strcat(read_dir, file_name, '.mat');
    display(replace('Saving %s', '%s', output_path));
    save(output_path,'dt2','fs');
end
display('COMPLETE');
exit(0);
