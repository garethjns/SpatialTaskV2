function figs = updateRespMessage(figs, params, txt)

% Check if current message exists and remove
if isfield(figs, 'respText') && ~isempty(figs.respText)
    delete(figs.respText)
    figs.respText = [];
end

% Set position
% X: Centre, adjusted for length of text
offset = 3*length(txt);
X = round(params.screenCalib.figPos(3)/2) - offset;
% Y: A little off bottom
Y = params.screenCalib.figPos(4)-50;

% And stick in figure
figure(figs.resp)
figs.respText = text(X, Y, txt);