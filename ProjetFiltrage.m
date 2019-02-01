clf

% Il faut importer le fichier pour qu'il s'appelle data_noise
% Normalement, le temps est sur la deuxième colonne et les valeurs sur la
% troisième pour que l'algorithme marche

% Sélectionnez "Import Data" puis retirez les trois premières lignes pour
% n'avoir que les valeurs


% Matrice des numéros
M_num = [ '1' '2' '3' 'A'
          '4' '5' '6' 'B'
          '7' '8' '9' 'C'
          '*' '0' '#' 'D' ];
       
% Initialisation
Nb_num = 10
N = floor(length(dtmf_noise(:,3))/10)
E = 1/( dtmf_noise(2,2) - dtmf_noise(1,2) )

% Matrice des fréquences possibles
F_list = [697 770 852 941 1209 1336 1477 1633];

% Création des variables
puissance = zeros(1,8);
max2 = zeros(10,8);
indexmax2 = zeros(10,8);
Num = ['' '' '' '' '' '' '' '' '' ''];

% Boucle pour chaque numéro
for l = 0:Nb_num-1
    
%     Boucle sur les 8 fréquences
    for j = 1:8
        F = F_list(j);
        k = floor( 0.5 + N*F/E );
        w = k * ( 2*pi/N );
        coeff = 2 * cos(w);

        q1 = 0;
        q2 = 0;

%         Boucle sur les échantillons à partir de l'algorithme de Goertzel
%         J'ai pris 1.5 fois la taille pour un numéro afin que si il n'est 
%         pas parfaitement centré à son emplacement, l'algorithme ne se 
%         trompe pas
        for i = 1:1.5*N
            ind = floor((l-0.75)*N) + i;
            if ind < length(dtmf_noise(:,3)) 
                if ind > 0
                    q0 = coeff*q1 - q2 + dtmf_noise(ind,3);
                    q2 = q1;
                    q1 = q0;
                end
            end
        end

        puissance(j) =  q1*q1 + q2*q2 - q1*q2*coeff;
    end
    
%     Trace une figure avec chaque puissance pour chaque fréquence
%     Chaque numéro a sa courbe et est indiqué par son ordre 
%     (exemple : "06 00 00 00 00", le 6 aura la courbe 2)
    plot(puissance, 'DisplayName', num2str(l+1));
    legend('-DynamicLegend');
    hold all;
    
%     max2 contient les maximums des puissances de chaque numéro tandis que
%     indexmax2 contient les indexs de ces maximums
    [max2(l+1, :), indexmax2(l+1, :)]=sort(puissance,'descend');
    
%     A partir d'eux et de la matrice des numéros, on peut obtenir le
%     numéro total
    if indexmax2(l+1, 1) > 4
        Num(l+1) = M_num(indexmax2(l+1,2), indexmax2(l+1,1)-4);
    else
        Num(l+1) = M_num(indexmax2(l+1,1), indexmax2(l+1,2)-4);
    end
end

% On affiche le numéro total
Num
