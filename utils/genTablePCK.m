function genTablePCK(pckAlgs, dataset, filename)
% Generate a latex table for the pck values of all methods

%% open file for writting
fileID = fopen(filename, 'w');

%% add headers to the file

if strcmpi(dataset, 'flic')
    header = sprintf('Method & Elbow & Wrist %s\n','\\');
elseif strcmpi(dataset, 'lsp')
    header = sprintf('Method & Head & Shoulder & Elbow & Wrist & Hip & Knee  & Ankle & Total %s\n','\\');
else
    error(['Undefined dataset: ' dataset])
end

fprintf(fileID,'%s\n',header);

%% generate data
for ialg=1:1:size(pckAlgs,2)
    % fetch data + name 
    pck = pckAlgs{ialg}{1};
    name = pckAlgs{ialg}{3};
    
    % assert data
    if strcmpi(dataset, 'flic') 
        assert(size(pck,2)==12)
        row = sprintf('%s  & %1.1f & %1.1f %s\n',name,...
            (pck(end,2)+pck(end,5))/2,(pck(end,3)+pck(end,6))/2,'\\');
    elseif strcmpi(dataset, 'lsp') 
        assert(size(pck,2)==15)
        row = sprintf('%s  & %1.1f & %1.1f  & %1.1f  & %1.1f  & %1.1f  & %1.1f & %1.1f & %1.1f %s\n',name,...
            (pck(end,13)+pck(end,14))/2,(pck(end,9)+pck(end,10))/2,...
            (pck(end,8)+pck(end,11))/2,(pck(end,7)+pck(end,12))/2,...
            (pck(end,3)+pck(end,4))/2,(pck(end,2)+pck(end,5))/2,...
            (pck(end,1)+pck(end,6))/2,pck(end, 15),'\\');
    end
    
    % print to file
    fprintf(fileID,'%s\n',row);

end

%% close file
fclose(fileID);

end


