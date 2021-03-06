function myMatrixColor = extractColor(colorImagePath)
isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;
if isOctave
	pkg load image
end
imdata = imread(colorImagePath);
[rows,cols,rgb] = size(imdata);
half_horizontal = idivide(int32(rows), 2, 'round');
orig_color=squeeze(imdata(half_horizontal,:,:));

white = [255,255,255];
% Il numero di colori massimo puo' essere impostato
% arbitrariamente alto, la matrice viene tagliata
% alla fine con il numero effettivo di colori trovati.
max_num_color = 100;
myMatrixColor = zeros(max_num_color, 3, 'uint8');
myMatrixColor(1, :) = white;
last_pixel = white;
indice = 2;
for i=1:cols
    % Puo' essere fatto in quanto la barra dei colori e' ordinata.
    test = last_pixel ~= orig_color(i,:);
    if test(1) == 1 | test(2) == 1 | test(3) ==1
        myMatrixColor(indice, :) = orig_color(i, :);
        last_pixel = orig_color(i, :);
        indice = indice + 1;
    end
end
% Rimozione dei valori della matrice non riempiti.
myMatrixColor = myMatrixColor(1:indice-1,:);
[num_colors, rgb] = size(myMatrixColor);

% Generazione dello spazio lineare da aggiungere alla matrice.
col_to_add = zeros(1, num_colors);
col_to_add(1) = 0;
col_to_add(2:num_colors) = linspace(0,1,num_colors-1);

myMatrixColor = im2double(myMatrixColor);
myMatrixColor = [myMatrixColor col_to_add'];
end
