%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Author: Shamus Roeder
%   WAV File Extraction program for the RION DA-20
% 	
%   DA-20 Manual Download Link: https://www.viaxys.com/app/download/10048456/DA-20+Instruction+Manual+40750.pdf
%   THIS FILE'S PURPOSE IS TO EXTRACT VALUES FOR THE PURPOSE OF FURTHER MODIFICATION.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef DA_20_data
    properties (Access = private)
        % These values descrube the dataset as a whole
        file_source                 % String containing the path to the original wav file
        data_table                  % Timetable of samples for all active channels
        active_channels             % Cell array of names of active channels
        active_channels_bool        % Logical array for indexing active channels in other arrays
        fs                          % double describing the sampling frequency
        start_time                  % datetime value describing when the recording began
        
        %These values are arrays that describe the 4 channels
        value_per_bit               % Double array, Channel unit A/D conversion measurement amount for each channel, 0 when off
        value_per_volt              % Double array, 1Vpk measurement amount of each channel, 0 when off, 1 when uncalibrated
        units                       % string array containg “m/s2”, “EU”, “dB” or “V”, describing the units being measured
        input_range                 % string array, input range before 1Vpk calibration
                 
        low_pass_filter_numeric     % Converts the LowPassFilter_array to a numeric value in Hertz
        low_pass_filter_string      % Converts the LowPassFilter_array to strings for the values for convenient display 
        
        high_pass_filter_numeric    % Converts the LowPassFilter_array to a numeric value in Hertz
        high_pass_filter_string     % Converts the LowPassFilter_array to strings for the values for convenient display
        overload_info               % uint16 array describing the overload incidence during recording in each channel
        
        CCLD_string                 % string array showing the CCLD information for each channel
        dB_reference                % EU value for 0 dB in each channel, Zero when no dB conversion is carried out
        
        input_coupling_string       % string array showing the input setting information for each channel
        
    end
    properties (Access = private, Hidden = true)
        % There properties are all directly from the data directly drawn and
        % interpreted from the WAV file that will be deleted when the
        % clean_object method is run. Feel free to modify the use of the 
        % clean_object method and modify these into being public if you'd 
        % like, whatever works best for you. I'm only keeping this here for
        % future developers' benefit.
        
        %RIFF Chunk
        RIFF_chunkID                        % "RIFF"
        RIFF_dwChunkSize                    % Chunk size (in bytes)   
        RIFF_formType                       % "WAVE"
        
        %fmt sub chunk
        fmt_chunkID                         % "fmt"
        fmt_dwChunkSize                     % Chunk size (in bytes): 16
        fmt_wFormatTag                      % Data format: 1 (PCM)
        fmt_wChannels                       % Channel number: 1 to 4
        fmt_dwSamplesPerSec                 % Sampling frequency 
        fmt_dwAvgBytesPerSec                % Number of data bytes per second (all channels) 
        fmt_wBlockAlign                     % Number of bytes per data: channel number × 2 
        fmt_wBitsPerSample                  % Number of bits/data channel: 16 
        
        %rion sub chunk (DA-20 specific)
        rion_chunkID                        % “rion”
        rion_dwChunkSize                    % Chunk size (in bytes): 460
        
        %Recording parameters extration
        nMaker                              % Maker name: “RION”
        ProductType                         % Product type: spaces if empty 
        nId                                 % Device ID: Integer value
        nFileVersion                        % File version: 1 to
        nCpuVersion                         % CPU version: *.*.***
        nDspVersion                         % DSP version: *.*.***

        Ch1ValuePerBit                      % Channel unit A/D conversion measurement amount
        Ch2ValuePerBit                      % (the product of this value and the A/D conversion value is the measurement amount) 
        Ch3ValuePerBit                      % (DATA of data chunk is the A/D conversion value
        Ch4ValuePerBit                      % When OFF, the value is zero.

        Ch1ValuePerVolt                     % 1Vpk measurement amount of each channel
        Ch2ValuePerVolt                     % (corresponds to EU value, sensor sensitivity, etc.)
        Ch3ValuePerVolt                     % When OFF, the value is zero,
        Ch4ValuePerVolt                     % 1 without calibration

        Ch1Unit                             % Left-aligned measurement amount
        Ch2Unit                             % Blanks are padded with spaces.
        Ch3Unit                             % “m/s2”, “EU”, “dB”, “V”
        Ch4Unit                             % OFF settings are all “ ”(space)

        Ch1InputRange                       % Left-aligned input range
        Ch2InputRange                       % (before 1Vpk calibration) 
        Ch3InputRange                       % Blanks are padded with spaces. 
        Ch4InputRange                       % “1V”, “0.01V” etc.

        dwCh1LowPassFilter                  % Low-pass filter of each channel
        dwCh2LowPassFilter                  % 0: OFF,
        dwCh3LowPassFilter                  % 6: 100 Hz, 7: 500 Hz, 10: 1 kHz
        dwCh4LowPassFilter                  %

        dwCh1HighPassFilter                 %
        dwCh2HighPassFilter                 % High-pass filter of each channel
        dwCh3HighPassFilter                 % 0: OFF, 10: 0.3 Hz, 15: 10 Hz
        dwCh4HighPassFilter                 %
 
        dwTriggerType                       % Trigger type 10: Level, 40: External, 50: External Gate
        dwTriggerMode                       % Trigger mode 10: Free, 20: Single, 30: Repeat
        Reserved1                           % Always 0
        dwTriggerChannel                    % Trigger channel: 1 to 4 
        dwTriggerLevel                      % Trigger level: unit is %
        dwPreTrigger                        % Pre-trigger: Seconds unit (equals pre-time) 
        Reserved2                           % Always 0
        StartTime                           % Recording start time: YyyyMmDd HhMmSs0 (space between d and H) Example: 2005/06/28, 8:30 is “20050628 0830000”

        nCh1OverloadInfo                    %
        nCh2OverloadInfo                    % Overload incidence during recording in each channel
        nCh3OverloadInfo                    % 0: no, 1: yes
        nCh4OverloadInfo                    %

        Ch1Memo                             %
        Ch2Memo                             % Comment string for each channel 
        Ch3Memo                             % Used by DA-20 Viewer Software
        Ch4Memo                             %

        dwPause                             % Number of pause incidences during recording: 0 to
        Reserved3                           % Always 0

        Ch1CCLD                             % CCLD information for each channel 
        Ch2CCLD                             % 0: DC/AC 
        Ch3CCLD                             % 1: CCLD 
        Ch4CCLD                             % 2: CHG (using VP-80)

        Ch1dBReference                      %
        Ch2dBReference                      % EU value for 0 dB in each channel 
        Ch3dBReference                      % Zero when no dB conversion is carried out
        Ch4dBReference                      %

        nVoiceMemo                          % Voice memo setting 0: OFF (Marker), 1: Voice Only, 
                                            % 2: Voice/Input Zero when no voice memo data are 
                                            % present with Voice/Input setting 

        wInputCoupling                      % Input setting information 
                                            % 0: OFF, 1: AC, 2: DC, 3: CCLD, 
                                            % 4: reserved, 5: CHARGE 
                                            % D15 to D12 Using above code for channel 4 
                                            % D11 to D8 Using above code for channel 3 
                                            % D7 to D4 Using above code for channel 2 
                                            % D3 to D0 Using above code for channel 1

        dwSerialNr                          % Serial number
        nRepeatTriggerNu                    % Number of trigger incidences Repeat trigger sequential number (0 to)
        nVoice                              % No. of voice memo or marker recordings
        Reserved4                           % ---------

        %memo sub chunk (fixed to 40 kB, DA-20 specific) 
        memo_chunkID                        % “memo”
        memo_dwChunkSize                    % Chunk size (in bytes): 1024 × 40 - 8 = 40952
        memo_TIMEDATA                       % Recording voice memo or marker information MEMORECTIMEFORMAT×3412 = 40944
        memo_dummy                          % For adjusting overall sub chunk size to 40 kB

        %paus sub chunk (fixed to 40 kB, DA-20 specific)
        paus_chunkID                        % “paus”
        paus_dwChunkSize                    % Chunk size (in bytes): 1024 × 40 - 8 = 40952
        paus_TIMEDATA                       % Recording pause information MEMORECTIMEFORMAT×3412 = 4094
        paus_dummy                          % For adjusting overall sub chunk size to 40 kB

        %data sub chunk 
        data_chunkID                        % “data” 
        data_dwChunkSize                    % Waveform data size (in bytes)
        DATA                                % Waveform data
        
        % These are the transient holding properties 
        low_pass_filter_raw                 % holding property for interpreting the original value encoding scheme
        high_pass_filter_raw                % holding property for interpreting the original value encoding scheme
        CCLD_raw                            % holding property for interpreting the original value encoding scheme
        input_coupling_raw                  % holding property for interpreting the original value encoding scheme
        memos 
    end
    methods
        function obj = DA_20_data(fullFileName) % Object constructor
            if nargin > 1
                error("Error in calling DA_20_data object constructor, too many input arguments.\nDA_20_data takes in one full file name or can be left blank to allow for user file selection.\n");
            end
            
            if nargin == 0
                % If the user does not declare the file within the
                % function, then the user is prompted to select a file to
                % import
                startingFolder = userpath;
                defaultFileName = fullfile(startingFolder, '*.*');
                [baseFileName, folder] = uigetfile(defaultFileName, 'Select WAV dataset generated by a RION DA-20.'); % Allows the user to pick out the specific file instead of having to manually enter it
                
                if isinteger(baseFileName)
                    assert((baseFileName ~= 0), "User clicked cancel button instead of selecting a WAV file, exiting constructor.\n")
                    % User clicked the Cancel button.
                end
                fullFileName = fullfile(folder, baseFileName);
            end
            
            [~, ~, file_extension] = fileparts(fullFileName);
            assert((lower(file_extension) == ".wav"), "User submitted a non .wav format file.")
            % Checking that this is indeed a .WAV file, will throw an
            % assertion error otherwise
            
            fileID = fopen(fullFileName);
            A = uint8(transpose(fread(fileID, Inf, 'uint8', 0, 'l'))); % Literally takes in the whole file an an array
            fclose(fileID);                                            % Closes file since it's now an array
            
            obj.file_source = fullFileName; % records what file it came from
            obj = obj.extract_data(A);      % extracts the data from the array into the generated object
            obj = obj.interpret_data;       % transforms the extracted data into a more usable form
            obj = obj.remove_extra_data;    % delete superfluous information to save memory
        end
        function export_as_csv(obj, save_file_name)
            % export_as_csv exports the acceleration data timetable as a csv
            if ~(exist('save_file_name', 'var')) % if the variable 
                                                 % save_file_name is not 
                                                 % declared, we prompt the 
                                                 % user to enter one 
                                                 % manually
                prompt_string = strcat('Enter the file name for the outputted csv for the data acquired from ', obj.file_source);
                
                [~, name, ~] = fileparts(obj.file_source); % Only takes the body of the name
                filter = {'*.csv'; '*.mat'; '*.slx'};      % Limiting the file types displayed
                [baseFileName, folder] = uiputfile(filter, prompt_string, strcat(name, '.csv')); % Allows the user to pick out the specific file to overwrite or 
                save_file_name = fullfile(folder, baseFileName);      
            end
            
            if strcmp(save_file_name, 'date') % If the user puts 'date' as a string as the save file name, it will name it the date and time.
                formatOut = 'mmddyyyyHHMMSS';
                save_file_name = datestr(now,formatOut);
            end  
            writetimetable(obj.data_table, save_file_name, 'Delimiter',','); % Saves the data
        end  
        function plot_data(obj)
            % plot_data plots the acceleration data as a stacked plot for
            % quick reference
            figure()
            stackedplot(obj.data_table);
        end
        function tabled_data = get_channel_details(obj)
            % Produces a table of details about all active channels
            
            pure_accel = obj.data_table{:,:}; 
            % Pulls the acceleration data from the data_table
            
            holding_matrix_1 = [obj.units(obj.active_channels_bool); ...
                mean(pure_accel, 1); ...
                max(pure_accel, [], 1); ...
                min(pure_accel, [], 1); ...
                obj.value_per_bit(obj.active_channels_bool); ...
                obj.value_per_volt(obj.active_channels_bool); ...
                ];
            holding_matrix_2 = [cellstr(obj.low_pass_filter_string(obj.active_channels_bool)); ...
                cellstr(obj.high_pass_filter_string(obj.active_channels_bool)); ...
                cellstr(obj.CCLD_string(obj.active_channels_bool)); ...
                ];
            holding_matrix_3 = num2cell([obj.dB_reference(obj.active_channels_bool); ...
                obj.overload_info(obj.active_channels_bool)]);
            holding_matrix_4 = cellstr(obj.input_range(obj.active_channels_bool));
            holding_cell = [num2cell(holding_matrix_1); holding_matrix_2; ...
                holding_matrix_3; holding_matrix_4]; 
            % Reassembles all these metrics into a single cell array to form a table
            % Must take use the obj.active_channels_bool as an index to
            % ensure that we only show the active channels.
            
            tabled_data = cell2table(holding_cell, ...
                'VariableNames', obj.active_channels, ...
                'RowNames', {'Units', 'Mean', 'Max', 'Min', ...
                'ValuePerBit', 'ValuePerVolt', 'LowPassFilter', ...
                'HighPassFiler', 'CCLD_Info', ...
                'dBReference', 'OverloadIncidence', 'InputRange'}); 
            % Outputs a summary of details for each channel
        end
        function get_model_info(obj)
            % Provides a simple readout of the model information for the
            % RION DA_20 
            fprintf('\nMaker name: %s\nProduct type: %s\nDevice ID: %d\nFile version: %d\nCPU version: %s\nDSP version: %s\n', ...
                obj.nMaker,obj.ProductType,obj.nId,obj.nFileVersion,obj.nCpuVersion,obj.nDspVersion);  
        end
        function t = get_simple_time_vector(obj)
            % creates a simple double time vector for the data starting at 
            % zero. Units are in seconds
            t = transpose((0: 1: height(obj.data_table)-1)/obj.fs); 
        end
        function accel = get_simple_accel_matrix(obj)
            % quickly and conveniently provides a matrix of acceleration
            % data
            accel = obj.data_table{:,:};
        end
        function channel_accel = get_channel_accel(obj, num)
            % Provides a vector of the acceleration for a specific channel
            assert(obj.active_channels_bool(num), 'The selected channel is not active.')
            switch num
                case 1
                    channel_accel = obj.data_table.Channel_1;
                case 2
                    channel_accel = obj.data_table.Channel_2;
                case 3
                    channel_accel = obj.data_table.Channel_3;
                case 4
                    channel_accel = obj.data_table.Channel_4;
            end          
        end
    end
    
    methods (Access = private)
        function obj = extract_data(obj, A)
            %RIFF Chunk
            obj.RIFF_chunkID = char(A(1:4));                          % “RIFF”
            obj.RIFF_dwChunkSize = typecast(A(5:8), 'uint32');        % Chunk size (in bytes) 
            obj.RIFF_formType = char(A(9:12));                        % “WAVE”

            %fmt sub chunk
            obj.fmt_chunkID = char(A(13:16));                         % “fmt”
            obj.fmt_dwChunkSize = typecast(A(17:20), 'uint32');       % Chunk size (in bytes): 16
            obj.fmt_wFormatTag = typecast(A(21:22), 'uint16');        % Data format: 1 (PCM)
            obj.fmt_wChannels = typecast(A(23:24), 'uint16');         % Channel number: 1 to 4
            obj.fmt_dwSamplesPerSec = typecast(A(25:28), 'uint32');   % Sampling frequency 
            obj.fmt_dwAvgBytesPerSec = typecast(A(29:32), 'uint32');  % Number of data bytes per second (all channels) 
            obj.fmt_wBlockAlign = typecast(A(33:34), 'uint16');       % Number of bytes per data: channel number × 2 
            obj.fmt_wBitsPerSample = typecast(A(35:36), 'uint16');    % Number of bits/data channel: 16 

            %rion sub chunk (DA-20 specific)
            obj.rion_chunkID = char(A(37:40));                        % “rion”
            obj.rion_dwChunkSize = typecast(A(41:44), 'uint32');      % Chunk size (in bytes): 460
            
            R = A(45:504);                                            % Recording parameters and other information of DA-20

            %Recording parameters extration
            obj.nMaker = char(R(1:4));                                % Maker name: “RION”
            obj.ProductType = char(R(5:12));                          % Product type: spaces if empty 
            obj.nId = typecast(R(13:16), 'uint32');                   % Device ID: Integer value
            obj.nFileVersion = typecast(R(17:20), 'uint32');          % File version: 1 to
            obj.nCpuVersion = char(R(21:28));                         % CPU version: *.*.***
            obj.nDspVersion = char(R(29:36));                         % DSP version: *.*.***

            obj.Ch1ValuePerBit = typecast(R(37:44), 'double');        % Channel unit A/D conversion measurement amount
            obj.Ch2ValuePerBit = typecast(R(45:52), 'double');        % (the product of this value and the A/D conversion value is the measurement amount) 
            obj.Ch3ValuePerBit = typecast(R(53:60), 'double');        % (DATA of data chunk is the A/D conversion value
            obj.Ch4ValuePerBit = typecast(R(61:68), 'double');        % When OFF, the value is zero.       

            obj.Ch1ValuePerVolt = typecast(R(69:76), 'double');       % 1Vpk measurement amount of each channel
            obj.Ch2ValuePerVolt = typecast(R(77:84), 'double');       % (corresponds to EU value, sensor sensitivity, etc.)
            obj.Ch3ValuePerVolt = typecast(R(85:92), 'double');       % When OFF, the value is zero,
            obj.Ch4ValuePerVolt = typecast(R(93:100), 'double');      % 1 without calibration
            
            obj.Ch1Unit = string(char(R(100:108)));                   % Left-aligned measurement amount
            obj.Ch2Unit = string(char(R(109:116)));                   % Blanks are padded with spaces.
            obj.Ch3Unit = string(char(R(117:124)));                   % “m/s2”, “EU”, “dB”, “V”
            obj.Ch4Unit = string(char(R(125:132)));                   % OFF settings are all “ ”(space)

            obj.Ch1InputRange = string(char(R(133:140)));             % Left-aligned input range
            obj.Ch2InputRange = string(char(R(141:148)));             % (before 1Vpk calibration) 
            obj.Ch3InputRange = string(char(R(149:156)));             % Blanks are padded with spaces. 
            obj.Ch4InputRange = string(char(R(157:164)));             % “1V”, “0.01V” etc.
            
            obj.dwCh1LowPassFilter = typecast(R(165:168), 'uint32');  % Low-pass filter of each channel
            obj.dwCh2LowPassFilter = typecast(R(169:172), 'uint32');  % 0: OFF,
            obj.dwCh3LowPassFilter = typecast(R(173:176), 'uint32');  % 6: 100 Hz, 7: 500 Hz, 10: 1 kHz
            obj.dwCh4LowPassFilter = typecast(R(177:180), 'uint32');  %

            obj.dwCh1HighPassFilter = typecast(R(181:184), 'uint32'); %
            obj.dwCh2HighPassFilter = typecast(R(185:188), 'uint32'); % High-pass filter of each channel
            obj.dwCh3HighPassFilter = typecast(R(189:192), 'uint32'); % 0: OFF, 10: 0.3 Hz, 15: 10 Hz
            obj.dwCh4HighPassFilter = typecast(R(193:196), 'uint32'); %

            obj.dwTriggerType = typecast(R(197:200), 'uint32');       % Trigger type 10: Level, 40: External, 50: External Gate
            obj.dwTriggerMode = typecast(R(201:204), 'uint32');       % Trigger mode 10: Free, 20: Single, 30: Repeat
            obj.Reserved1 = typecast(R(205:208), 'uint32');           % Always 0
            obj.dwTriggerChannel = typecast(R(209:212), 'uint32');    % Trigger channel: 1 to 4 
            obj.dwTriggerLevel = typecast(R(213:220), 'double');      % Trigger level: unit is %
            obj.dwPreTrigger = typecast(R(221:224), 'uint32');        % Pre-trigger: Seconds unit (equals pre-time) 
            obj.Reserved2 = typecast(R(225:228), 'uint32');           % Always 0
            obj.StartTime = char(R(229:244));                         % Recording start time: YyyyMmDd HhMmSs0 (space between d and H) Example: 2005/06/28, 8:30 is “20050628 0830000”
            
            
            obj.nCh1OverloadInfo = typecast(R(245:246), 'uint16');    %
            obj.nCh2OverloadInfo = typecast(R(247:248), 'uint16');    % Overload incidence during recording in each channel
            obj.nCh3OverloadInfo = typecast(R(249:250), 'uint16');    % 0: no, 1: yes
            obj.nCh4OverloadInfo = typecast(R(251:252), 'uint16');    %

            obj.Ch1Memo = string(char(R(253:284)));                   %
            obj.Ch2Memo = string(char(R(285:316)));                   % Comment string for each channel 
            obj.Ch3Memo = string(char(R(317:348)));                   % Used by DA-20 Viewer Software
            obj.Ch4Memo = string(char(R(349:380)));                   %

            obj.dwPause = typecast(R(381:384), 'uint32');             % Number of pause incidences during recording: 0 to
            obj.Reserved3 = typecast(R(385:388), 'uint32');           % Always 0

            obj.Ch1CCLD = typecast(R(389:390), 'uint16');             % CCLD information for each channel 
            obj.Ch2CCLD = typecast(R(391:392), 'uint16');             % 0: DC/AC 
            obj.Ch3CCLD = typecast(R(393:394), 'uint16');             % 1: CCLD 
            obj.Ch4CCLD = typecast(R(395:396), 'uint16');             % 2: CHG (using VP-80)
            
            obj.Ch1dBReference = typecast(R(397:404), 'double');      %
            obj.Ch2dBReference = typecast(R(405:412), 'double');      % EU value for 0 dB in each channel 
            obj.Ch3dBReference = typecast(R(413:420), 'double');      % Zero when no dB conversion is carried out
            obj.Ch4dBReference = typecast(R(421:428), 'double');      %

            obj.nVoiceMemo = typecast(R(429:430), 'uint16');          % Voice memo setting 0: OFF (Marker), 1: Voice Only, 
                                                                      % 2: Voice/Input Zero when no voice memo data are 
                                                                      % present with Voice/Input setting 

            obj.wInputCoupling = dec2hex(typecast(R(431:434), ...     % Input setting information 
                'uint32'));                                           % 0: OFF, 1: AC, 2: DC, 3: CCLD, 
                                                                      % 4: reserved, 5: CHARGE 
                                                                      % D15 to D12 Using above code for channel 4 
                                                                      % D11 to D8 Using above code for channel 3 
                                                                      % D7 to D4 Using above code for channel 2 
                                                                      % D3 to D0 Using above code for channel 1

            obj.dwSerialNr = typecast(R(435:438), 'uint32');          % Serial number
            obj.nRepeatTriggerNu = typecast(R(439:440), 'uint16');    % Number of trigger incidences Repeat trigger sequential number (0 to)
            obj.nVoice = typecast(R(441:442), 'uint16');              % No. of voice memo or marker recordings
            obj.Reserved4 = R(443:460);                               % ---------

            %memo sub chunk (fixed to 40 kB, DA-20 specific) 
            obj.memo_chunkID = char(A(505:508));                      % “memo”
            obj.memo_dwChunkSize = typecast(A(509:512), 'uint32');    % Chunk size (in bytes): 1024 × 40 - 8 = 40952
            obj.memo_TIMEDATA = A(513:41456);                         % Recording voice memo or marker information MEMORECTIMEFORMAT×3412 = 40944
            obj.memo_dummy = A(41457:41464);                          % For adjusting overall sub chunk size to 40 kB

            %paus sub chunk (fixed to 40 kB, DA-20 specific)
            obj.paus_chunkID = char(A(41465:41468));                  % “paus”
            obj.paus_dwChunkSize = typecast(A(41469:41472), 'uint32');% Chunk size (in bytes): 1024 × 40 - 8 = 40952
            obj.paus_TIMEDATA = A(41473:82416);                       % Recording pause information MEMORECTIMEFORMAT×3412 = 4094
            obj.paus_dummy = A(82417:82424);                          % For adjusting overall sub chunk size to 40 kB

            %data sub chunk 
            obj.data_chunkID = char(A(82425:82428));                  % “data” 
            obj.data_dwChunkSize = typecast(A(82429:82432), 'uint32');% Waveform data size (in bytes)
            obj.DATA = typecast(A(82433:end), 'int16');               % Waveform data
        end
        function obj = interpret_data(obj)
            CHANNEL_LABELS = {'Channel_1', 'Channel_2', 'Channel_3', ...
                'Channel_4'};
            
            % Create a series of keys to decode the information in the file
            LOW_PASS_KEY = {0, Inf, "OFF"; 6, 100, "100 Hz"; ...
                7, 500, "500 Hz"; 10, 1000, "1 kHz"};
            HIGH_PASS_KEY = {0, 0, "OFF"; 10, 0.3, "0.3 Hz"; ...
                15, 10, "10 Hz"};
            CCLD_KEY = ["DC/AC", "CCLD", "CHG (using CP-80)"];
            INPUT_COUPLING_KEY = ["OFF", "AC", "DC", "CCLD", ...
                "reserved", "CHARGE"];  
            
            % Then we transform all the separated channel variables into
            % arrays.
            obj.value_per_bit = [obj.Ch1ValuePerBit, ...
                obj.Ch2ValuePerBit, obj.Ch3ValuePerBit, ...
                obj.Ch4ValuePerBit];
            obj.value_per_volt = [obj.Ch1ValuePerVolt, ...
                obj.Ch2ValuePerVolt, obj.Ch3ValuePerVolt, ...
                obj.Ch4ValuePerVolt];
            obj.units = [obj.Ch1Unit, obj.Ch2Unit, obj.Ch3Unit, ...
                obj.Ch4Unit];
            obj.input_range = [obj.Ch1InputRange, ... 
                obj.Ch2InputRange, obj.Ch3InputRange, ...
                obj.Ch4InputRange];
            obj.dB_reference = [obj.Ch1dBReference, ...
                obj.Ch2dBReference, obj.Ch3dBReference, ...
                obj.Ch4dBReference];
            obj.overload_info = [obj.nCh1OverloadInfo, ...
                obj.nCh2OverloadInfo, obj.nCh3OverloadInfo, ...
                obj.nCh4OverloadInfo];
            obj.memos = [obj.Ch1Memo, obj.Ch2Memo, obj.Ch3Memo, ...
                obj.Ch4Memo];
            
            obj.input_coupling_raw = transpose(str2num(transpose(obj.wInputCoupling))); % keep str2num,str2double doesn't separate out the channel values
            obj.low_pass_filter_raw = [obj.dwCh1LowPassFilter, ... 
                obj.dwCh2LowPassFilter, obj.dwCh3LowPassFilter, ...
                obj.dwCh4LowPassFilter];
            obj.high_pass_filter_raw = [obj.dwCh1HighPassFilter, ... 
                obj.dwCh2HighPassFilter, obj.dwCh3HighPassFilter, ...
                obj.dwCh4HighPassFilter];
            obj.CCLD_raw = [obj.Ch1CCLD, obj.Ch2CCLD, obj.Ch3CCLD, ...
                obj.Ch4CCLD];
            
            % Preallocate these arrays before we iterate through them
            obj.low_pass_filter_numeric = zeros(1, 4);
            obj.low_pass_filter_string = strings(1, 4);
            
            obj.high_pass_filter_numeric = zeros(1, 4);
            obj.high_pass_filter_string = strings(1, 4);
            
            obj.CCLD_string = strings(1,4);
            obj.input_coupling_string = strings(1,4);
            
            % Use the keys in order to interpret the raw labels
            for i = 1:4
                switch obj.low_pass_filter_raw(i)
                    case LOW_PASS_KEY{1,1}
                        obj.low_pass_filter_numeric(i) = LOW_PASS_KEY{1,2};
                        obj.low_pass_filter_string(i) = LOW_PASS_KEY{1,3};
                    case LOW_PASS_KEY{2,1}
                        obj.low_pass_filter_numeric(i) = LOW_PASS_KEY{2,2};
                        obj.low_pass_filter_string(i) = LOW_PASS_KEY{2,3};
                    case LOW_PASS_KEY{3,1}
                        obj.low_pass_filter_numeric(i) = LOW_PASS_KEY{3,2};
                        obj.low_pass_filter_string(i) = LOW_PASS_KEY{3,3};
                    case LOW_PASS_KEY{4,1}
                        obj.low_pass_filter_numeric(i) = LOW_PASS_KEY{4,2};
                        obj.low_pass_filter_string(i) = LOW_PASS_KEY{4,3};
                end
                switch obj.high_pass_filter_raw(i)
                    case HIGH_PASS_KEY{1,1}
                        obj.high_pass_filter_numeric(i) = HIGH_PASS_KEY{1,2};
                        obj.high_pass_filter_string(i) = HIGH_PASS_KEY{1,3};
                    case HIGH_PASS_KEY{2,1}
                        obj.high_pass_filter_numeric(i) = HIGH_PASS_KEY{2,2};
                        obj.high_pass_filter_string(i) = HIGH_PASS_KEY{2,3};
                    case HIGH_PASS_KEY{3,1}
                        obj.high_pass_filter_numeric(i) = HIGH_PASS_KEY{3,2};
                        obj.high_pass_filter_string(i) = HIGH_PASS_KEY{3,3};
                end
                obj.CCLD_string(i) = CCLD_KEY(obj.CCLD_raw(i) +1 );
                obj.input_coupling_string(i) = INPUT_COUPLING_KEY(obj.input_coupling_raw(i) + 1);
                
            end
            
            obj.fs = double(obj.fmt_dwSamplesPerSec);       % Pull out the sample rate, name it something simple
            
            % Make the start time value make sense
            goal_time_format = 'yyyyMMdd HHmmss';
            obj.start_time = datetime(obj.StartTime, 'InputFormat', goal_time_format);     
            
            % Create a boolean array describing what channels are active
            obj.active_channels_bool = obj.input_coupling_raw > 0; 
            num_channels_active = length(obj.input_coupling_raw(obj.active_channels_bool));
            
            obj.active_channels = CHANNEL_LABELS(obj.active_channels_bool);
            bit_conversion_active = obj.value_per_bit(obj.active_channels_bool);
            
            % Transform the data from a single vector into as many columns
            % as there are channels
            channel_data = double(transpose(reshape(transpose(obj.DATA), num_channels_active, []))).*bit_conversion_active;
            
            % Create a table from this that is going to be converted into a
            % timetable
            interim_table = array2table(channel_data, 'VariableNames', obj.active_channels);
            
            % Create the timetable
            obj.data_table = table2timetable(interim_table, 'SampleRate', obj.fs);
            
            % Add the start time value to all time values
            obj.data_table.Time = obj.data_table.Time + obj.start_time;
        end 
        function obj = remove_extra_data(obj)
            % This method removes what I believe to be unnecessary, bulky
            % data for the purpose of saving memory. This currently runs
            % after data extraction and interpretation. If you do not want
            % this to happen, remove that line of code in the constructor
            % method.
            
            obj.memo_TIMEDATA = "cleared by remove_extra_data";
            obj.DATA = "cleared by remove_extra_data";
            obj.paus_TIMEDATA = "cleared by remove_extra_data";
        end
    end   
end
        
