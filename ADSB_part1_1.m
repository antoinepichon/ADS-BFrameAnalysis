%% Projet TS226 : Pichon Antoine / Portelli Florian : 2ème Année Télécommunications

clear all;
close all;

%% Initialisation des variables


fe=20e+06;  %Fréquence d'échantillonnage : fe=1/Te
Ds=1e+06; %Débit Symbole : Ds=1/Ts
Te=1/fe;
Ts=1/Ds;
Fse=Ts/Te; %Facteur de sur-échantillonnage

N_fft=512; %Nombre de points pour réaliser les fft
Ns=1000;
Sb=randi([0 1], 1, Ns); % séquence de 1000 bits générée aléatoirement de manière uniforme
Ss=zeros(1,Ns);

f=([0:N_fft-1]/N_fft-0.5).*fe;
%% Modulation PPM

%%Emetteur 

%Association bits <-> Symbole
for i=1:1:Ns
    if(Sb(i)==0)
        Ss(i)=-1;
    elseif(Sb(i)==1)
        Ss(i)=1;
    end
end

Ss_bis=upsample(Ss,Fse); % Sur-échantillonnage

% Forme d'onde biphase p(t)

A=-0.5*ones(1,Fse/2);
B=0.5*ones(1,Fse/2);
p=[A B];

Rsl_moy=([0.5 0.425 0.35 0.275 0.2 0.125 0.15 0.175 0.2 0.225 0.25 0.25 0.25 0.25 0.25 0.25 0.25 0.25 0.25 0.25 0.25]);

t_rslmoy=([0:Ts/10:2*Ts]);
figure,
plot(t_rslmoy,Rsl_moy);
ylabel('Amplitude');
xlabel('Temps(µs)');
title('\fontsize{16}\bfAutocorrélation moyennée du signal sl(t) sur [0,2Ts]');


Sl=0.5 + conv(Ss_bis, p); % Filtrage de mise en forme


% Question 11 : Tracer Sl(t) pour les 25 premiers bits
T=[0:Te:25*Ts-Te];
figure,
plot(T,Sl(1:500));
xlabel('Temps(s)');
ylabel('Sl(t)');
ylim([-0.2 1.2]);
title('\fontsize{16}\bf Allure temporelle du signal Sl(t)')


% Question 12 : Tracer le diagramme de l'oeil de durée 2Ts pour les 100
% premiers bits envoyés


eyediagram(Sl(1:2000),2*Fse, 2*Ts);
ylim([-0.2 1.2]);
title('\fontsize{16}\bf Diagramme de l''oeil de Sl(t)')

% Question 13 : DSP de Sl(t) 


% DSP Expérimentale :


DSP_Sl_Exp=fftshift(abs(fft(Sl,N_fft)).^2);
 
 figure,
  %plot((1:N_fft)/N_fft, fftshift(abs(fft(Sl, N_fft)).^2)/N_fft^2);
 plot(f,DSP_Sl_Exp./sqrt(sum(DSP_Sl_Exp.^2)))
 title(' \fontsize{16}\bf DSP expérimentale de Sl(t)');
 xlabel('Normalized Frequency')
 ylabel('Amplitude')
xlim([-fe/2 fe/2-fe/N_fft]);

% DSP Théorique : 
 Dirac = [zeros(1,length(f)/2) 1 zeros(1,length(f)/2-1)];
 DSP_Sl_Th = Dirac/4 + (pi^2*Ts^3*f.^2)/(16*N_fft*Te).*sinc(Ts*f/2).^4;
 figure,
 plot(f, DSP_Sl_Th./sqrt(sum(DSP_Sl_Th.^2)), 'r');
 title('\fontsize{16}\bf DSP Théorique de S_l(t)');
 xlabel('Normalized Frequency')
 ylabel('Amplitude')
xlim([-fe/2 fe/2-fe/N_fft]);






    






