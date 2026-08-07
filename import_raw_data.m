%% The fuction 'import_raw_data' reads in a .tsv file (raw data) in a line by line manner and saves it as an array for MATLAB
% Input: 
% Filename -> this would be the entire pathway to where on the computer
% this raw data is located 
% (ex. '/Users/RudyAcosta/Desktop/Research/Pd figures/Manuscript/Figure5.tsv')
% Output:
% data -> MATLAB array of raw data, originally in a .tsv file, now also
% transposed
% Data is separated by Columns:
% X , Y , Z, noise (not used), V, i, Line Number, noise (not used), second
% voltage (not used), ? (not used)
%% Initialize
function data = import_raw_data(Filename)
 %%
 % - Open file.
 fId  = fopen(Filename) ;
 % - Read first line, convert to double, determine #columns.
 if fId>0
 line  = fgetl( fId ) ;
 row   = sscanf( line, '%f\t' )' ;
 nCols = numel( row ) ;
 % - Preallocate data, copy first row, init loop counter.
 data      = zeros(10, nCols ) ;
 data(1,:) = row ;
 rowCnt    = 1 ;
 %% Loop over rest of the file.
 while ~feof( fId )
    disp(rowCnt)
    rowCnt = rowCnt + 1 ;
    % - Read line, convert and store.
    line = fgetl( fId ) ;
    data(rowCnt,:) = sscanf( line, '%f\t' )' ;
 end
%%  Close file.
 fclose( fId ) ;
 %% reflect and save data
 data=data';

 save([Filename(1:end-4) '.mat'],'data')
 else
     disp('Can''t open file!!')
 end
end