module Proofs {
    use 0x0::Transaction;
    use 0x0::Vector;

    struct DummyEvent { 
        b: bool 
    }

    struct Credential{
        digest : vector<u8>,
        holder : address,
        signed : bool,
        revoked : bool,
        time: u64,
        owners_signed : vector<address>,
        owners : vector<address>,
        quorum : u64,
    }

    resource struct CredentialProof{
        quorum: u64,
        holder: address,
        issuer: address,
        owners : vector<address>,
        valid : bool, // signed by quorum of owners
        revoked : bool,
        digest : vector<u8>,
        credentials: vector<Credential>
    }

    resource struct RevocationProof {
        credentialProof: CredentialProof,
        reason: vector<u8>,
        nonce: u64 // counter from issuer
    }

    // stored with holder
    resource struct CredentialAccount{
        issuer : address,
        holder : address,
        credential_proofs : vector<CredentialProof>   
    }

    // // stored with issuer
    resource struct RevocationProofs{
        credential_proofs : vector<RevocationProof>   
    }

    public fun getCredentialAccountProofLength(): u64 acquires CredentialAccount {
        let credential_account_ref: &CredentialAccount;
        let len: u64;
        
        credential_account_ref = borrow_global<CredentialAccount>(Transaction::sender());
        len = Vector::length<CredentialProof>(&credential_account_ref.credential_proofs);
        len
    }

    fun setCredentialProofDigest(credential_proof : &mut CredentialProof, digest: vector<u8>){
        *&mut credential_proof.digest = digest;
    }

    public fun moveCredentialsProofToAccount(credential_proof: CredentialProof, aggregation: vector<u8>) acquires CredentialAccount{
        let credential_account_ref: &mut CredentialAccount;
        
        // *&mut (credential_proof).digest = h"";
        setCredentialProofDigest(&mut credential_proof, aggregation);

        // TODO : check if credential is valid
        credential_account_ref = borrow_global_mut<CredentialAccount>(Transaction::sender());
        Vector::push_back<CredentialProof>(
            &mut credential_account_ref.credential_proofs, 
            credential_proof
        );
    }

    public fun getCredentialByDigest(credentials: &vector<Credential>, digest: &vector<u8>): (u64 , bool){
        let len: u64;
        let i: u64;
        let credential_ref: &Credential;

        i = 0;
        len = Vector::length<Credential>((credentials));

        while ((i) < (len)) {
            credential_ref = Vector::borrow<Credential>(credentials, i);
            if (*(digest) == *&(credential_ref).digest) return (i, true);
            i = i + 1;
        };

        (0, false)
    }

    public fun getCredentialProofIndexByHolderAddress(credential_proofs: &vector<CredentialProof>,holder :&address): (u64 , bool){
        let len: u64;
        let i: u64;
        let credential_proof_ref: &CredentialProof;

        i = 0;
        len = Vector::length<CredentialProof>((credential_proofs));

        while ((i) < (len)) {
            credential_proof_ref = Vector::borrow<CredentialProof>((credential_proofs), (i));
            
            if (*(holder) == *&(credential_proof_ref).holder) {
                return (i, true)
            };
            i = (i) + 1;
        };

        (0, false)
    }

    public fun getCredentialProofIndexByDigest(credential_proofs: &vector<CredentialProof>, digest: &vector<u8>, check_valid: bool): (u64 , bool) {
        let len: u64;
        let i: u64;
        let credential_proof_ref: &CredentialProof;

        i = 0;
        len = Vector::length<CredentialProof>((credential_proofs));

        while ((i) < (len)) {
            credential_proof_ref = Vector::borrow<CredentialProof>((credential_proofs), (i));
            
            if (*(digest) == *&(credential_proof_ref).digest) {
                if((check_valid)){
                    if(*&(credential_proof_ref).valid){
                        return (i, true)
                    };
                }else{
                    return (i, true)
                };
            };
            i = (i) + 1;
        };

        (0, false)
    }

    public fun getCredentialHolder(_credential: &Credential): address{
        return *&(_credential).holder
    }

    public fun getCredentialProofHolder(_credential_proof: &CredentialProof): address{
        return *&(_credential_proof).holder
    }

    public fun insertCredential(credential_proofs_mut: &mut vector<CredentialProof>, _credential: Credential): bool{
        let len: u64;
        let i: u64;
        let credential_proof_ref: &mut CredentialProof;
        let holder: address;

        holder = getCredentialHolder(& _credential);

        i = 0;
        len = Vector::length<CredentialProof>(freeze((credential_proofs_mut)));
        while (i < len) {
            credential_proof_ref = Vector::borrow_mut<CredentialProof>(credential_proofs_mut, i);
            if (holder == *&(credential_proof_ref).holder) {
                Vector::push_back<Credential>(
                    &mut (credential_proof_ref).credentials, 
                    (_credential)
                );
                return true
            };
            i = (i) + 1;
        };

        false
    }

    public fun getCredentialIndexByDigest(credentials: &vector<Credential>, digest: &vector<u8>): (u64 , bool) {
        let len: u64;
        let i: u64;
        let credential_ref: &Credential;

        i = 0;
        len = Vector::length<Credential>((credentials));

        while ((i) < (len)) {
            credential_ref = Vector::borrow<Credential>((credentials), (i));
            
            if (*(digest) == *&(credential_ref).digest) {
                return (i, true)
            };
            i = (i) + 1;
        };

        (0, false)
    }

    public fun signAsOwner(credential: &mut Credential){
        let sender_address: address;
        let owners: &vector<address>;
        let owners_signed: &mut vector<address>;
        
        sender_address = Transaction::sender();
        owners = &(credential).owners;
        owners_signed = &mut (credential).owners_signed;
        
        Transaction::assert(Vector::contains<address>((owners), &sender_address), 1);
        Transaction::assert(!Vector::contains<address>(freeze((owners_signed)), &sender_address), 1);

        Vector::push_back<address>(
                    (owners_signed), 
                    (sender_address)
                );
    }

    public fun hasSignatureConsensus(credential: &mut Credential): bool{
        let owners_signed_len: u64;
        let owners_signed: &mut vector<address>;
        owners_signed = &mut (credential).owners_signed;
        owners_signed_len = Vector::length<address>(freeze((owners_signed)));
        
        if(owners_signed_len == *&(credential).quorum){
            *&mut (credential).signed = true;
            return (true)
        };
        
        false
    }

    public fun newCredential(holder: address, digest: vector<u8>, _owners: vector<address>, _quorum: u64): Credential{
         Credential{
            digest : (digest),
            holder : (holder),
            signed : false,
            revoked : false,
            time: 1, // replace this with time.now() from newer libra version
            owners_signed : Vector::empty<address>(),
            owners : (_owners),
            quorum: (_quorum)
        }
    }

    public fun newCredentialAccount(_issuer: address, _holder: address){
        move_to_sender<CredentialAccount>(
            CredentialAccount {
                issuer : (_issuer),
                holder : (_holder),
                credential_proofs : Vector::empty<CredentialProof>()
            }
        );
    }

    public fun newCredentialProof(_issuer: address, _holder: address, _quorum: u64, _owners: vector<address>): CredentialProof {
        CredentialProof{
            quorum : (_quorum),
            holder : (_holder),
            issuer : (_issuer),
            owners : (_owners),
            valid : false, 
            revoked : false,
            digest : x"",
            credentials : Vector::empty<Credential>(),
        }     
    }

    public fun getCredentialProofDigests(credential_proof : &CredentialProof): vector<vector<u8>>{
        let digests: vector<vector<u8>>; 
        let len: u64;
        let i: u64;
        let credentials: &vector<Credential>;
        let credential_ref: &Credential;
        let credential_proof_holder : address;

        credential_proof_holder = getCredentialProofHolder((credential_proof));
        credentials = &(credential_proof).credentials;
        digests = Vector::empty<vector<u8>>();

        i = 0;
        len = Vector::length<Credential>((credentials));

        while ((i) < (len)) {
            credential_ref = Vector::borrow<Credential>((credentials), (i));
            Transaction::assert(credential_proof_holder == *&(credential_ref).holder, 890);
            Vector::push_back<vector<u8>>(
                &mut digests, 
                *&(credential_ref).digest
            );
           
            i = (i) + 1;
        };

        digests
    }

    public fun aggregateDigests(digests: vector<vector<u8>>): vector<u8>{
        let aggregated_digest: vector<u8>;
        let digests_mut: &mut vector<vector<u8>>;
        let digest: vector<u8>;
        let len: u64;
        let i: u64;

        aggregated_digest = x"";
        digests_mut = &mut digests;
        i = 0;
        len = Vector::length<vector<u8>>(freeze((digests_mut)));

        loop {
            digest = *Vector::borrow_mut<vector<u8>>((digests_mut), (i));
            Vector::append<u8>(&mut aggregated_digest, (digest));

            i = (i) + 1;
            if ((i) >= (len)) {
                break
            };
        };
        
        aggregated_digest
    }

    // aggregates digests in a credential account
    public fun compileCredentialProof(holder:address): (vector<vector<u8>>,vector<u8>) acquires CredentialAccount{
        let credential_account_ref: &mut CredentialAccount;
        // let digests: vector<vector<u8>>;
        // let aggregated_digest : vector<u8>;
        
        credential_account_ref = borrow_global_mut<CredentialAccount>((holder));
        Transaction::assert(*&(credential_account_ref).issuer == Transaction::sender(), 90);
        
        aggregateCredentialProofs(&(credential_account_ref).credential_proofs)
        // *&mut (credential_account_ref).digest = (aggregated_digest);
    }

    // aggregate credential proof digests
    public fun aggregateCredentialProofs(credential_proofs: &vector<CredentialProof>): (vector<vector<u8>> , vector<u8>){
        let digests: vector<vector<u8>>;
        let credential_proof_ref: &CredentialProof;
        let len: u64;
        let i: u64;
        let digests_copy: vector<vector<u8>>;
        
        i = 0;
        len = Vector::length<CredentialProof>((credential_proofs));
        digests = Vector::empty<vector<u8>>();
        digests_copy = Vector::empty<vector<u8>>();

        while ((i) < (len)) {
            credential_proof_ref = Vector::borrow<CredentialProof>((credential_proofs), (i));
            
            Vector::push_back<vector<u8>>(
                &mut digests, 
                *&(credential_proof_ref).digest
            );

            Vector::push_back<vector<u8>>(
                &mut digests_copy, 
                *&(credential_proof_ref).digest
            );
            
            i = (i) + 1;
        };
        
        (digests_copy, aggregateDigests(digests))
    }

}

//! new-transaction
// module that allows issuer to mark a credential resource for recepients
module EarmarkedProofs {
    use {{default}}::Proofs;
    use 0x0::Transaction;
    use 0x0::Vector;
    // import 0x0.Hash;

//     struct MyEvent { 
//         b: bool 
//     }

    struct DigestHolder {
        digests : vector<vector<u8>>,
        holder : address,
        aggregation : vector<u8>
    }

    //--------------------------------
    // Resources
    //--------------------------------

    // A wrapper containing a Libra coin and the address of the recipient the
    // coin is earmarked for.
    resource struct LoggedProofs {
        owners : vector<address>,
        credential_proofs: vector<Proofs::CredentialProof>,
        credentials: vector<Proofs::Credential>
    }

    resource struct DigestHolderProofs {
        digest_holders: vector<DigestHolder>
    }

    resource struct RevocationProofs {
        revoked_digests: vector<vector<u8>>
    }

//     //--------------------------------
//     // Methods
//     //--------------------------------

    public fun is_digest_revoked(digest:  vector<u8>, issuer: address): bool acquires RevocationProofs{
        let requester_revocation_proofs: &RevocationProofs;
        requester_revocation_proofs = borrow_global<RevocationProofs>((issuer));

        // check if the digest is revoked
        Vector::contains< vector<u8>>(&(requester_revocation_proofs).revoked_digests, &digest)
    }

    // Works only if called by issuer
    public fun revoke_digest(digest:  vector<u8>) acquires RevocationProofs{
        let requester_revocation_proofs: &mut RevocationProofs;
        requester_revocation_proofs = borrow_global_mut<RevocationProofs>(Transaction::sender());

        // Transaction::assert that the digest is not already revoked
        Transaction::assert(!Vector::contains< vector<u8>>(&(requester_revocation_proofs).revoked_digests, &digest), 400);
        Vector::push_back< vector<u8>>(
                &mut (requester_revocation_proofs).revoked_digests,
                (digest)
            );   
    }

    public fun getCredentialProofLength(addr: address): u64 acquires LoggedProofs {
        let requester_logged_proofs: &LoggedProofs;
        let len: u64;
        
        requester_logged_proofs = borrow_global<LoggedProofs>((addr));
        len = Vector::length<Proofs::CredentialProof>(&(requester_logged_proofs).credential_proofs);
        len
    }

    public fun getCredentialLength(issuer: address): u64 acquires LoggedProofs {
        let requester_logged_proofs: &LoggedProofs;
        let len: u64;
        
        requester_logged_proofs = borrow_global<LoggedProofs>((issuer));
        len = Vector::length<Proofs::Credential>(&(requester_logged_proofs).credentials);
        len
    }

    public fun hasOwnership(addr: address, issuer: address): bool acquires LoggedProofs {
        let requester_logged_proofs: &LoggedProofs;
        
        requester_logged_proofs = borrow_global<LoggedProofs>((issuer));
        Vector::contains<address>(&(requester_logged_proofs).owners, &addr)
    }

    public fun hasLoggedProofs(addr: address): bool {
        let exists: bool;
        exists = exists<LoggedProofs>((addr));
        exists
    }

    public fun hasRevocationProofs(addr: address): bool {
        let exists: bool;
        exists = exists<RevocationProofs>((addr));
        exists
    }

    public fun createIssuerLoggedProof(_owners: vector<address>){
        move_to_sender<LoggedProofs>(
            LoggedProofs {
                owners: (_owners),
                credential_proofs : Vector::empty<Proofs::CredentialProof>(),
                credentials : Vector::empty<Proofs::Credential>()
            }
        );

        move_to_sender<DigestHolderProofs>(
            DigestHolderProofs {
                digest_holders: Vector::empty<DigestHolder>()
            }
        );

        move_to_sender<RevocationProofs>(
            RevocationProofs {
                revoked_digests: Vector::empty<vector<u8>>()
            }
        );
    }

    // sign credential
    // invoked by : owner
    // TODO:
    // 2 check if quorums on credential has been reached
    // 3  credential to appropriate credential proof
    // 4 compute digest of credential proof based on all included credential
    public fun signCredential(issuer: address, digest: vector<u8>) acquires LoggedProofs{
        let requester_logged_proofs: &mut LoggedProofs;
        let sender_address: address;
        let credential_index:u64;
        let credential_exists:bool;
        let has_consensus: bool;
        
        let owners: &vector<address>;
        let credentials: &mut vector<Proofs::Credential>;
        let credential_proofs: &mut vector<Proofs::CredentialProof>;
        let signed_credential: Proofs::Credential;
        let signed_credential_mut: &mut Proofs::Credential;
        let successfulTransfer: bool;
        
        sender_address = Transaction::sender();

        // 1 sign the credential associated with vector<u8>
        // ownership verification
        requester_logged_proofs = borrow_global_mut<LoggedProofs>((issuer));
        owners = &(requester_logged_proofs).owners;
        credentials = &mut (requester_logged_proofs).credentials;
        credential_proofs = &mut (requester_logged_proofs).credential_proofs;
        Transaction::assert(Vector::contains<address>((owners), &sender_address), 198);

        // Fetch credential
        (credential_index, credential_exists) = Proofs::getCredentialIndexByDigest(freeze((credentials)), &digest);
        Transaction::assert((credential_exists), 199);
        
        signed_credential = Vector::swap_remove<Proofs::Credential>((credentials), (credential_index));
        signed_credential_mut = &mut signed_credential;
        Proofs::signAsOwner((signed_credential_mut));

        // handle signed transactions
        has_consensus = Proofs::hasSignatureConsensus((signed_credential_mut));
        if((has_consensus)){
            // push credential to credential proof
            successfulTransfer = Proofs::insertCredential(
                (credential_proofs), 
                *(signed_credential_mut)
            );
            Transaction::assert((successfulTransfer), 49);
        }else{
            // push credential to logged credentials 
            Vector::push_back<Proofs::Credential>(
                (credentials), 
                *(signed_credential_mut)
            );
        };

        
    }

    // TODO: register credential inserts into earmarked proof credentials vector
    public fun registerCredential(credential: Proofs::Credential) acquires LoggedProofs{
        let requester_logged_proofs: &mut LoggedProofs;

        requester_logged_proofs = borrow_global_mut<LoggedProofs>(Transaction::sender());
         Vector::push_back<Proofs::Credential>(
            &mut (requester_logged_proofs).credentials, 
            (credential)
        );
    }

    // called by issuer when registering CP
    // fails if it is not an issuer running this
    public fun registerCP(cp: Proofs::CredentialProof) acquires LoggedProofs{
        let requester_logged_proofs: &mut LoggedProofs;
        requester_logged_proofs = borrow_global_mut<LoggedProofs>(Transaction::sender());
        Vector::push_back<Proofs::CredentialProof>(
            &mut (requester_logged_proofs).credential_proofs, 
            (cp)
        );
    }

    // called by receipient to claimCP. Can only be claimed if a quorum of owners have signed
    // params : 
    // issuer : address of the issuing course
    public fun claimCP(issuer: address) acquires LoggedProofs, DigestHolderProofs{
        let cp_index: u64;
        let cp_exists: bool;
        let credential_proof: Proofs::CredentialProof;
        let requester_logged_proofs: &mut LoggedProofs;
        let sender_address: address;
        let aggregation: vector<u8>;
        sender_address = Transaction::sender();

        //TODO: validate that issuer knows the sender (in issuerresource.holders)
        requester_logged_proofs = borrow_global_mut<LoggedProofs>((issuer));
        (cp_index, cp_exists) = Proofs::getCredentialProofIndexByHolderAddress(& (requester_logged_proofs).credential_proofs, &sender_address);
        
        // check that a credential proof exists
        Transaction::assert((cp_exists), 42);
        
        // re credential proof from issuer resource
        credential_proof = Vector::swap_remove<Proofs::CredentialProof>(&mut (requester_logged_proofs).credential_proofs, (cp_index));

        // save digest as digest holder proof
        aggregation = createDigestHolderProof(&mut credential_proof, (issuer));

        //  credential proof to holder account
        Proofs::moveCredentialsProofToAccount((credential_proof),(aggregation));
    }

    fun createDigestHolderProof(credential_proof : &mut Proofs::CredentialProof, issuer: address): vector<u8> acquires DigestHolderProofs{
        let digests: vector<vector<u8>>;
        let digest_holder: DigestHolder;
        let requester_dh_proofs: &mut DigestHolderProofs;
        let holder: address;
        let aggregation: vector<u8>;

        requester_dh_proofs = borrow_global_mut<DigestHolderProofs>((issuer));

        holder = Proofs::getCredentialProofHolder(freeze((credential_proof)));
        digests = Proofs::getCredentialProofDigests(freeze((credential_proof)));
        aggregation = Proofs::aggregateDigests(copy digests);
        
        digest_holder = DigestHolder {
            digests : move digests,
            holder : holder,
            aggregation : copy aggregation
        };

        Vector::push_back<DigestHolder>(
            &mut (requester_dh_proofs).digest_holders, 
            (digest_holder)
        );

        aggregation
    }


    public fun aggregateProofs(digests: vector<vector<u8>>): vector<u8>{
        let aggregated_digest: vector<u8>;
        // let aggregated_digest_mut: &mut vector<u8>;
        let digests_mut: &mut vector<vector<u8>>;
        let digest: vector<u8>;
        let len: u64;
        let i: u64;

        aggregated_digest = x"";

        digests_mut = &mut digests;
        i = 0;
        len = Vector::length<vector<u8>>(freeze((digests_mut)));

        loop {
            digest = *Vector::borrow_mut<vector<u8>>((digests_mut), (i));
            Vector::append<u8>(&mut aggregated_digest, (digest));

            i = (i) + 1;
            if ((i) >= (len)) {
                break
            };
        };
        
        aggregated_digest
    }
    
    //digest - aggregated digest to verify
    public fun verifyCredential(digest: vector<u8>, issuer: address, student: address): bool acquires DigestHolderProofs, RevocationProofs{
        // let local_digest: vector<u8>;
        let requester_dh_proofs: &DigestHolderProofs;
        let len: u64;
        let i: u64;
        let digest_holder_ref: &DigestHolder;

        // check if the digest is revoked
        Transaction::assert(!is_digest_revoked(copy digest, issuer), 400);
        
        // loop through digest holder proof
        // if the digest belongs to student
        i = 0;
        requester_dh_proofs = borrow_global<DigestHolderProofs>((issuer));
        len = Vector::length<DigestHolder>(&(requester_dh_proofs).digest_holders);

        while ((i) < (len)) {
            digest_holder_ref = Vector::borrow<DigestHolder>(&(requester_dh_proofs).digest_holders, (i));
            
            // means that the issuer issued credential proof for the student
            if (student == digest_holder_ref.holder) {
                // check for matching aggregation
                if(copy digest == *&digest_holder_ref.aggregation) return (true)
            };
            i = (i) + 1;
        };        
        false
    }

    public fun generateCredentialAccountDigest(holder:address) acquires DigestHolderProofs{
        let digests: vector<vector<u8>>;
        let aggregated_digest : vector<u8>;
        let requester_dh_proofs: &mut DigestHolderProofs;
        let digest_holder: DigestHolder;
        
        requester_dh_proofs = borrow_global_mut<DigestHolderProofs>(Transaction::sender());
        (digests, aggregated_digest) = Proofs::compileCredentialProof((holder));
        
        digest_holder = DigestHolder {
            digests : move digests,
            holder : holder,
            aggregation : move aggregated_digest
        };

        Vector::push_back<DigestHolder>(
            &mut (requester_dh_proofs).digest_holders, 
            (digest_holder)
        );
        
    }


//     // Events
//     public fun emit_event(val: bool) {
//         let handle: LibraAccount.EventHandle<MyEvent>;
//         handle = LibraAccount.new_event_handle<MyEvent>();
//         LibraAccount.emit_event<MyEvent>(&mut handle, MyEvent{ b: (val) });
//         LibraAccount.destroy_handle<MyEvent>((handle));
//         
//     }

//     // TODO: Aggregate credential proof as a root issuer
//     public fun aggregateCredentialProofs(holder:address){
//         
//     }
}