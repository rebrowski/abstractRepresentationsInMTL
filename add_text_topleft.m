function add_text_topleft(ax, annotation, marginH, marginV, fontSize, ...
                          fontWeight)
%% add_text_topleft(ax, annotation, marginH, marginV, fontSize, fontWeight)

% annotate subplots with a Letter
if ~exist('marginH', 'var') || isempty(marginH)
    marginH = 0.08;
end
if ~exist('marginV', 'var') || isempty(marginV)   
    marginV = 0.01;
end
if ~exist('fontSize', 'var') || isempty(fontSize)
fontSize = 16;
end
if ~exist('fontWeight', 'var') || isempty(fontWeight)
fontWeight = 'bold';
end

tl(1) = ax.Position(1)-marginH;
tl(2) = ax.Position(2) + ax.Position(4)+marginV;
tl(3) = tl(1) + marginH;
tl(4) = tl(2) + marginV;
ax2 = axes('Position', tl);
set(ax2, 'Color', 'none')
text(0,0, annotation, 'FontSize', fontSize, 'FontWeight', fontWeight, ...
     'HorizontalAlignment', 'left', 'VerticalAlignment', 'top')
axis off
