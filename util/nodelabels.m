function labels = nodelabels(dataset)

switch dataset
    case {'fve', 'felleman_vanessen'}
        Names = load('data/fve32.mat', 'Names'); 
        labels = arrayfun(@(idx) strtrim(Names.Names(idx,:)), 1:size(Names.Names,1), 'uni', 0);
    case {'mkv', 'markov'}
        fid = fopen('data/markov_retrograde.csv');
        labels = {};
        tline = fgetl(fid);
        while ischar(tline)
            tline = fgetl(fid);
            if ~ischar(tline)
                break;
            end
            commas = strfind(tline, ',');
            labels{end+1} = tline(1:commas(1)-1);
        end
        fclose(fid);
    case {'zng', 'zng_df', 'zng_ant', 'zng_ret', 'zingg'}
        p = 49;
        fid = fopen('data/zingg_labels.txt');
        labels = textscan(fid,'%s', p); labels = labels{1};
        fclose(fid);        
end