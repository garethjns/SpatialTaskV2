function replotRaw(data, tit)

figure; hold on
imshow('Background_wg.png')
hold on

for t = 1:height(data)
    corr = all(data.respBinAN{t} == data.PosBinLog{t},2);
    
    switch corr(1)
        case 0
            mk = 'x';
        case 1
            mk = 'o';
    end
    hSc = scatter(data.RawResponse{t}(1,1), ...
        data.RawResponse{t}(1,2), mk, ...
        'MarkerEdgeColor', 'r');
    
    switch corr(2)
        case 0
            mk = 'x';
        case 1
            mk = 'o';
    end
    scatter(data.RawResponse{t}(2,1),data.RawResponse{t}(2,2), ...
        'Marker', mk, ...
        'MarkerEdgeColor', 'k')
end

title(tit)
hgx(['Graphs\' tit, '_ResponseLocations'])
