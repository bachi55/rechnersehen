
Img = imread('verzerrt.png');
imshow(Img);

[ImgWidth,ImgHight,~] = size(Img)


%lass dir die 2 rotationspunkte geben
RotPoints = ginput(4);
p1 = [ RotPoints(1, :) 1 ]; 
p1 = p1.';
p2 = [ RotPoints(2, :) 1 ]; 
p2 = p2.';
p3 = [ RotPoints(3, :) 1 ]; 
p3 = p3.';
p4 = [ RotPoints(4, :) 1 ]; 
p4 = p4.';

x1 = [0 ; 0 ; 1];
x2 = [1; 0 ; 1];
x3 = [1 ; 1 ; 1];
x4 = [0 ; 1 ; 1];

%Ah = 0 

A = [ -x1'  0 0 0   p1(1)'*x1'; 0 0 0  -x1'  p1(2)'*x1' ;
    -x2'  0 0 0   p2(1)'*x2'; 0 0 0  -x2'  p2(2)'*x2' ;
    -x3'  0 0 0   p3(1)'*x3'; 0 0 0  -x3'  p3(2)'*x3' ;
    -x4'  0 0 0   p4(1)'*x4'; 0 0 0  -x4'  p4(2)'*x4' ];

% [U,S,V] = svd(A) eigenwert von S = 0 gibt spalte(n) in V für lösung an. 
% alternativ mit null(A)
h = null(A);

% H = [ h(1) h(2) h(3);
%       h(4) h(5) h(6);
%       h(7) h(8) h(9)]; 
H = reshape (h, [3,3])';





% Skalierungsfaktor für rücktrans. berechnen
% das ausgabe rechteck ist auf kantenlänge 1 normiert. das entspricht bla
% px oder so... daher umrandungs box

ImgEntZer = zeros(ImgWidth,ImgHight,3,'uint8');

% Image(y,x);

for i=0:ImgWidth %Y
    for j=0:ImgHight  %X
        s  = [j/ ImgHight ; i / ImgWidth ; 1];
        VerZerPkt = ( H * s) ;
        EnZerPkt =  [round(VerZerPkt(1)/VerZerPkt(3))  ; round(VerZerPkt(2)/VerZerPkt(3))];
        
        ImgEntZer(i+1,j+1,:) = Img(EnZerPkt(2),EnZerPkt(1),:);   
    end       
end

figure;
imshow(ImgEntZer);