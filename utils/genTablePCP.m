function genTablePCP(pcpAlgs, dataset, filename)
% Generate a latex table for the pck values of all methods

%% open file for writting
fileID = fopen(filename, 'w');

%% add headers to the file

if strcmpi(dataset, 'flic')
    header = sprintf('Method & Upper arm & Forearm %s\n','\\');
elseif strcmpi(dataset, 'lsp')
    header = sprintf('Method & Torso & Upper leg & Lower leg & Upper arm & Forearm & Head & PCP %s\n','\\');
else
    error(['Undefined dataset: ' dataset])
end

fprintf(fileID,'%s\n',header);

%% generate data
for ialg=1:1:size(pcpAlgs,2)
    % fetch data + name 
    pcp = pcpAlgs{ialg}{1};
    name = pcpAlgs{ialg}{3};
    
    % assert data
    if strcmpi(dataset, 'flic') 
        assert(size(pcp,2)==6)
        row = sprintf('%s  & %1.1f & %1.1f %s\n',name,...
            (pcp(end,1)+pcp(end,3))/2,(pcp(end,2)+pcp(end,4))/2,'\\');
    elseif strcmpi(dataset, 'lsp') 
        assert(size(pcp,2)==11)
        row = sprintf('%s  & %1.1f & %1.1f & %1.1f & %1.1f & %1.1f & %1.1f & %1.1f %s\n',name,...
            pcp(end,10),(pcp(end,2)+pcp(end,3))/2,...
            (pcp(end,1)+pcp(end,4))/2,(pcp(end,6)+pcp(end,7))/2,...
            (pcp(end,5)+pcp(end,8))/2,pcp(end,9),...
            pcp(end, 11),'\\');
    end
    
    % print to file
    fprintf(fileID,'%s\n',row);

end

%% close file
fclose(fileID);

end


