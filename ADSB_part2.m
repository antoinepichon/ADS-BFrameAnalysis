%% Pichon-Portelli Partie 2 : Traitement/décodage de signaux réels

% Trame ADS-B : préambule 8us - format voie descendante 5us - capacité 3us - 
%               @OACI 24us - données ADS-B 56us- bits de contrôle de parité
%               24us

%% Question 18

% D'après les tables des valeurs du FTC, on remarque que :
%   - FTC € [1,4] = infos d'identification
%   - FTC € [9,18] U [20,22] = infos de position en vol

%% Question 19
clear all;
close all;
clc

% On charge les trames à traiter
load('trames_20141120');

% Initialisation du registre
old_reg = struct('format',[],'type',[],'nom',[],'altitude',[],...
                 'cprFlag',[],'latitude',[],'longitude',[]);
old_reg.format = 'format';
old_reg.type = 'type';
old_reg.nom = 'Coucou';
old_reg.altitude = 'altitude';
old_reg.cprFlag = 'cprFlag';
old_reg.latitude = 'lat';
old_reg.longitude = 'long';

%% Application de la fonction bit2registre

% On boucle sur le nombre de trames à traiter
for i=1:21
    
% On prend la trames numéro i
bit_vector=trames_20141120(:,i);
ADSB_data=bit_vector(33:88);

% Application de la fonction bit2registre
new_reg=bit2registre(old_reg,bit_vector)

%% La fonction plot_google_map affiche des longitudes/lattitudes en degré décimaux,
MER_LON = -0.710648; % Longitude de l'aéroport de Mérignac
MER_LAT = 44.836316; % Latitude de l'aéroport de Mérignac

figure(1);
plot(MER_LON,MER_LAT,'.r','MarkerSize',20);% On affiche l'aéroport de Mérignac sur la carte
text(MER_LON+0.05,MER_LAT,'Merignac airport','color','r')
plot_google_map('MapType','terrain','ShowLabels',0) % On affiche une carte sans le nom des villes

xlabel('Longitude en degré');
ylabel('Lattitude en degré');

hold on;

%% Affichage d'un avion
switch bi2de(transpose(ADSB_data(1:5)));
    case {9,10,11,12,13,14,15,16,17,18,20,21,22}
        PLANE_LON = new_reg.longitude; % Longitude de l'avion
        PLANE_LAT = new_reg.latitude; % Latitude de l'avion
        Id_airplane='AF-255'; % Nom de l'avion
        plot(PLANE_LON,PLANE_LAT,'+b','MarkerSize',8);
        text(PLANE_LON+0.05,PLANE_LAT,Id_airplane,'color','b');        
end

end
