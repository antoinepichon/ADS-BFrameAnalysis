function [new_reg]=bit2registre(old_reg,bit_vector)

%% hexa = dec2hex(bin2dec(regexprep(num2str(X),'[^w"];")));
% Définition des différentes parties du vecteur de bits
DF = transpose(bit_vector(1:5));
CA = bit_vector(6:8);
addr_OACI = bit_vector(9:32);
ADSB_data = bit_vector(33:88);
FTC = transpose(ADSB_data(1:5));
% Définition du polynome générateur lié au CRC
poly_generator = [1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 0 0 0 0 0 0 1 0 0 1];
% Création d'un alphabet afin de pouvoir associer une lettre à chaque séquence codant
% les caractères des messages d'identification
alphabet={'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',... 
          'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',...
          '', '', '', '', '', 'SP', '', '', '', '', '', '', '', '', '', '',...
          '', '', '', '', '', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};
% Passage du polynôme générateur au CRC
CRC = crc.detector(poly_generator);
[outdata error] = detect(CRC,bit_vector);
if (error == 0)
    % Différents cas selon la valeur de FTC (Format Type Code)
    switch bi2de(FTC)
        %% Cas du message de position en vol
        case {9,10,11,12,13,14,15,16,17,18,20,21,22}
            % Initialisation de la structure associée
            new_reg = struct('format',[],'type',[],'adresse',[],'altitude',[],...
                     'cprFlag',[],'latitude',[],'longitude',[]);
            new_reg.type = bi2de(FTC);
            new_reg.format = bi2de(DF);
            new_reg.adresse = dec2hex(bin2dec(regexprep(num2str(...
                              transpose(addr_OACI)),'[^\w"]','')));
            %% Décodage de l'altitude
            alt_temp = zeros(1:11);
            % On supprime le 8ième bit inutile ici
            alt_temp(1:7) = ADSB_data(9:15);
            alt_temp(8:11) = ADSB_data(17:20);
            new_reg.altitude = 25*bi2de(alt_temp(1:11),'left-msb') - 1000 ;
            new_reg.cprFlag = ADSB_data(22);
            %% Décodage de la latitude
            r_lat = transpose(ADSB_data(23:39));
            LAT = bi2de(r_lat,'left-msb');
            Nz = 15;
            % 1ère étape : calcul de la grandeur D_lat
            D_lat = 360/(4*Nz - new_reg.cprFlag);
            % 2ème étape : calcul de la grandeur j
            lat_ref = 44.8065779;
            Nb = 17;
            j = floor(lat_ref/D_lat) + floor((1/2) + ((lat_ref - D_lat*...
                floor(lat_ref/D_lat))/D_lat) - (LAT/(2^Nb)));
            % 3ème étape : décodage final de la latitude
            new_reg.latitude = D_lat*(j + LAT/2^Nb);
            %% Décodage de la longitude
            r_lon = transpose(ADSB_data(40:56));
            LON = bi2de(r_lon,'left-msb');
            % 1ère étape : calcul de la grandeur D_lon
            if ((cprNL(new_reg.latitude) - new_reg.cprFlag) > 0)
                D_lon = 360/(cprNL(new_reg.latitude) - new_reg.cprFlag);
            elseif ((cprNL(new_reg.latitude) - new_reg.cprFlag) == 0)
                D_lon = 360;
            end
            % 2ème étape : calcul de la grandeur m
            lon_ref = -0.5995026;
            m = floor(lon_ref/D_lon) + floor((1/2) + ((lon_ref - D_lon*...
                floor(lon_ref/D_lon))/D_lon) - (LON/2^Nb));
            % 3ème étape : décodage final de la longitude
            new_reg.longitude = D_lon*(m + LON/2^Nb);
        %% Cas du message d'identification    
        case {1,2,3,4}
         % Initialisation de la structure associée
            new_reg = struct('format',[],'type',[],'categorie',[],'caractere1',[],...
                     'caractere2',[],'caractere3',[],'caractere4',[], 'caractere5',[],...
                     'caractere6',[],'caractere7',[],'caractere8',[]);
            new_reg.type = bi2de(FTC);
            new_reg.format = bi2de(DF);
            new_reg.categorie = ADSB_data(6:8); 
            % On remplit les caractères à l'aide de l'alphabet créé en convertissant
            % au préalable les séquences de bits correspondantes en décimal
            C1 = bi2de(fliplr(ADSB_data(9:14)'));
            new_reg.caractere1 = alphabet(C1);
            C2 = bi2de(fliplr(ADSB_data(15:20)'));
            new_reg.caractere2 = alphabet(C2);
            C3 = bi2de(fliplr(ADSB_data(21:26)'));
            new_reg.caractere3 = alphabet(C3);
            C4 = bi2de(fliplr(ADSB_data(27:32)'));    
            new_reg.caractere4 = alphabet(C4);
            C5 = bi2de(fliplr(ADSB_data(33:38)'));
            new_reg.caractere5 = alphabet(C5);
            C6 = bi2de(fliplr(ADSB_data(39:44)'));
            new_reg.caractere6 = alphabet(C6);
            C7 = bi2de(fliplr(ADSB_data(45:50)'));
            new_reg.caractere7 = alphabet(C7);
            C8 = bi2de(fliplr(ADSB_data(51:56)'));
            new_reg.caractere8 = alphabet(C8);
    end
else
    error;
end
end