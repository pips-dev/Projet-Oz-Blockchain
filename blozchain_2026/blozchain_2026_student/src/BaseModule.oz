functor
export
    decode:Decode
    executeBlockchain:ExecuteBlockchain
define

    %% STUDENT START:

    %% PUT ANY AUXILIARY/HELPER FUNCTIONS THAT YOU NEED
    fun {Pow X N}
        if N == 0 then 1
        else
            X*{Pow X N-1}
        end
    end

    fun {HashTransaction Transaction}
        case Transaction of transaction(nonce:Nonce sender:Sender receiver:Receiver value:Value) then
            (Nonce + Sender + Receiver + Value) mod {Pow 10 6}
        end
    end

    fun {SumTransactions Transactions Acc}
        case Transactions of nil then Acc
        [] H|T then
            {SumTransactions T Acc + {HashTransaction H}}
        end
    end

    fun {HashBlock Block}
        case Block of block(number:Number previousHash:PreviousHash transactions:Transactions) then
            (Number + PreviousHash + {SumTransactions Transactions 0}) mod {Pow 10 6}
        end
    end

    fun {DigitCount N Acc}
        if N =< 0 then Acc
        else
            {DigitCount N div 10 Acc + 1}
        end
    end

    % effort : un entier positif représentant l’effort calculatoire nécessaire pour exécuter cette transaction ~=~ compléxité
    fun {EffortScore N Acc I}
        if I >= N then Acc
        else
            {EffortScore N Acc + {Pow 2 I} I + 1}
        end
    end
    
    fun {CalculateEffort Transaction}
        case Transaction of transaction(value:Value) then
            Len = {DigitCount Value 0}
        in
            {EffortScore Len 0 0}
        end
    end

    %nonce : un entier représentant le nombre de transactions qu’un utilisateur a envoyées.
    fun {GetLastNonce Sender Blockchain}
        case Blockchain of nil then 0
        [] Block|T then
            case Block of block(transactions:Transactions) then
                {FindLastNonce Sender Transactions {GetLastNonce Sender T}}
            end
        end
    end

    fun {FindLastNonce Sender Transactions LastFound}
        case Transactions of nil then LastFound
        [] T|Tr then
            case T of transaction(nonce:Nonce sender:S) then
                if S == Sender andthen Nonce > LastFound then
                    {FindLastNonce Sender Tr Nonce}
                else
                    {FindLastNonce Sender Tr LastFound}
                end
            end
        end
    end

    fun {ValidateTransaction Transaction Sender LastNonce Balance Blockchain}
        case Transaction of transaction(nonce:Nonce sender:Sender receiver:Receiver value:Value hash:Hash max_effort:MaxEffort) then
            Nonce == LastNonce + 1 andthen
            Hash == {HashTransaction Transaction} andthen
            Value >= 0 andthen
            MaxEffort > 0 andthen
            Balance >= Value andthen
            {CalculateEffort Transaction} =< MaxEffort
        end
    end

    fun {GetBalance Sender Genesis Blockchain}
    InitBalance = try {GetField Genesis Sender} catch _ then 0 end
    in  
        {CalculateBalance Sender InitBalance Blockchain}
    end

    fun {CalculateBalance Sender Acc Blockchain}
        case Blockchain of nil then Acc
        [] Block|Rest then
            case Block of block(transactions:Transactions) then
                NewAcc = {UpdateBalance Sender Acc Transactions}
            in
                {CalculateBalance Sender NewAcc Rest}
            end
        end
    end

    fun {UpdateBalance Sender Acc Transactions}
        case Transactions of nil then Acc 
        [] T|Tr then 
            case T of transaction(sender:S receiver:R value:V) then 
                if S == Sender then NewAcc = Acc - V
                elseif R == Sender then NewAcc = Acc + V
                else NewAcc = Acc end 
            in
                {UpdateBalance Sender NewAcc Tr}
            end
        end
    end

    fun {ValidateAllTransactions Transactions Genesis Blockchain}
        case Transactions of nil then true
        [] T|Tr then
            case T of transaction(sender:Sender) then
                LastNonce = {GetLastNonce Sender Blockchain}
                Balance = {GetBalance Sender Genesis Blockchain}
            in
                {ValidateTransaction T Sender LastNonce Balance Blockchain} andthen
                {ValidateAllTransactions Tr Genesis Blockchain}
            end
        end
    end

    fun {ValidateBlock Block PreviousBlock Genesis Blockchain}
        case Block of block(number:Number previousHash:PreviousHash transactions:Transactions hash:Hash) then
            Number == PreviousBlock.number + 1 andthen
            PreviousHash == {HashBlock PreviousBlock} andthen
            Hash == {HashBlock Block} andthen
            {ValidateAllTransactions Transactions Genesis Blockchain} andthen
            {SumEfforts Transactions 0} =< 300
        end
    end

    fun {GetPreviousBlock Number Blockchain}
        case Blockchain of nil then nil
        [] Block|T then
            case Block of block(number:Number) then Block
            else {GetPreviousBlock Number T} end
        end
    end

    fun {SumEfforts Transactions Acc}
        case Transactions of nil then Acc
        [] T|Tr then
            {SumEfforts Tr Acc + {CalculateEffort T}}
        end
    end

    fun {GetUserBalance User}
        case User of user(balance:B nonce:N) then B 
        [] nil then 0
    end

    fun {GetUserNonce User}
        case User of user(balance:B nonce:N) then N 
        [] nil then 0 
    end

    fun {MakeUser Balance Nonce}
        user(Balance:Balance nonce:Nonce)
    end 
    
    % http://mozart2.org/mozart-v1/doc-1.4.0/base/record.html : utilisation getfield pour accéder à la valeur d'un champs du nom address
    fun {GetUser State Address}
        try {GetField State Address} catch _ then nil end
    end

    % http://mozart2.org/mozart-v1/doc-1.4.0/tutorial/node3.html#label19 : utilisation de adjoint pour ajouter un user au début de la bonne addresse de state 
    fun {SetUser State Address User}
        {AdjoinAt State Address User}
    end

    % http://mozart2.org/mozart-v1/doc-1.4.0/base/record.html : utilisation de record.map afin d'itérer sur les champs de genesis et les remplacer par des reccord user
    fun {GenesisToState Genesis}
        
        % genesis(address1 : value1 address2 : value2 ...) -> genesis(address1 : user(balance:B nonce:N) address2:user(balance:B nonce:N))
        {Record.map Genesis fun {$ B} user(balance:B nonce:0) end}
    end

    %% STUDENT END

    %% Return a string representation of the secret
    fun {Decode Blockchain}
        {Decode_rec Blockchain ""}
    end

    % http://mozart2.org/mozart-v1/doc-1.4.0/tutorial/node3.html#label14 : utilisation de Int.toString 
    fun {Decode_Block Hash Acc}
        case Hash of nil then Acc
        [] H1|nil then Acc
        [] H1|H2|T then
            X = {String.toInt H1#H2} %%%%%%%%%%%%%%% POSSIBLEMENT CE QUI PEUT MERDER %%%%%%%%%%%%%%% 
            if (X mod 37 < 10) then
                Num = 36 
            else 
                Num = X mod 37 
            end
            {Decode_Block T Acc#{SecretTable Num}}
        end
    end
    
    % http://mozart2.org/mozart-v1/doc-1.4.0/tutorial/node3.html#label22 : concaténation de strings 
    fun {Decode_rec Blocks Acc}
        case Blocks of nil then Acc
        [] H|T then
            Block_String = {Decode_Block {Int.toString H.hash} ""} 
            {Decode_rec T Acc#Block_String}
        end
    end

    fun {SecretTable N}
        case N of 10 then "a"
            [] 11 then "b"
            [] 12 then "c"
            [] 13 then "d"
            [] 14 then "e"
            [] 15 then "f"
            [] 16 then "g"
            [] 17 then "h"
            [] 18 then "i"
            [] 19 then "j"
            [] 20 then "k"
            [] 21 then "l"
            [] 22 then "m"
            [] 23 then "n"
            [] 24 then "o"
            [] 25 then "p"
            [] 26 then "q"
            [] 27 then "r"
            [] 28 then "s"
            [] 29 then "t"
            [] 30 then "u"
            [] 31 then "v"
            [] 32 then "w"
            [] 33 then "x"
            [] 34 then "y"
            [] 35 then "z"
            [] 36 then " "
        end
    end

    % This function is the starting point of the execution
    % The GenesisState and the Transactions are given as input and the function is expected to bound the FinalState and the FinalBlockchain to their respective final values.
    proc {ExecuteBlockchain GenesisState Transactions FinalState FinalBlockchain}
        %% STUDENT START:
        %% TODO
        %% STUDENT END
    end
end