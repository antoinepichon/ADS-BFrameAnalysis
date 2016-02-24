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
Ns=112;
Sb=randint(1,Ns); % séquence de 112 bits générée aléatoirement de manière uniforme
Ss=zeros(1,Ns);
Bs=zeros(1,Ns);


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
Ep=p*transpose(p);

Sl=conv(Ss_bis,p); % Filtrage de mise en forme

% Bruit

nl=randn(size(Sl))*0; % Bruit blanc gaussien de variance nulle

yl=Sl+nl;


%% Recepteur 

p_bis=fliplr(p);

rl=conv(p_bis,yl); % Sortie du filtre de réception
rl_n=rl(Fse:Fse:length(rl)-Fse); % Echantillonnage au rythme Ts

A_n = 2*(rl_n > 0) - 1; % Prise de décision (si r_ln > 0 A_n = 1 sinon -1)

for k=1:1:length(A_n) % Association Symbole->Bits
    if (A_n(k)==-1) 
        Bs(k)=0;
    elseif (A_n(k)==1)
        Bs(k)=1;
    end
end

%TEB=sum(abs(Bs-Sb)/Ns) % Taux d'erreur binaire


% 5. TEB en fonction du rapport Eb/N0
SNRdB=[0:10];
for k=1:length(SNRdB)
    Nb_paquets=0;
    Error=0;
    while Error<100 && Nb_paquets<1000 %Mininum de 100 erreurs binaires de transmission
        Eb=Ep; % en effet : Eb=Ep*var(A)*Eg*(Tb/Ts) et Tb=Ts
        SNR(k)=10^(SNRdB(k)/10); 
        N0=Eb/SNR(k);
        nl=randn(size(Sl))*sqrt(N0/2); % Bruit blanc gaussien de variance N0/2
        yl=nl+Sl; 
        rl=conv(p_bis,yl);
        rl_n=rl(Fse:Fse:length(rl)-Fse); % Echantillonnage
        A_n2 = 2*(rl_n > 0) - 1; % Décision
        Bs2=(A_n2 + 1)/2; % Bits recus
        
        %TEB2(k)=(abs(Sb-Bs2)*ones(Ns,1))/Ns;
        Error=Error+(abs(Sb-Bs2)*ones(Ns,1));
        Nb_paquets=Nb_paquets+1;
        
    end
    
TEB2(k)=Error/(Ns*Nb_paquets);
end

Pb=1/2*erfc(sqrt(SNR)); %¨probabilité d'erreur binaire

figure(8);
semilogy(SNRdB,TEB2,'b');
hold on
semilogy(SNRdB,Pb,'r');
title('\fontsize{16}\bfEvolution du TEB en fonction du rapport Eb/N0 en dB');
legend('TEB exp','TEB theo');
hold off
grid on

