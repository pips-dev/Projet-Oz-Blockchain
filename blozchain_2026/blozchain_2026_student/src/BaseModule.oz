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
        case Transaction of transition(nonce:Nonce sender:Sender receiver:Receiver value:Value) then
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

    %% STUDENT END

    %% Return a string representation of the secret
    fun {Decode Blockchain}
        %% STUDENT START:
        %% TODO
        %% STUDENT END
    end

    % This function is the starting point of the execution
    % The GenesisState and the Transactions are given as input and the function is expected to bound the FinalState and the FinalBlockchain to their respective final values.
    proc {ExecuteBlockchain GenesisState Transactions FinalState FinalBlockchain}
        %% STUDENT START:
        %% TODO
        %% STUDENT END
    end
end