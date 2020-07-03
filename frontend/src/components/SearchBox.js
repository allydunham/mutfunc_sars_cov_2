import React, { useState } from "react";

const SearchBox = ({ setSearch }) => {
    const [newSearch, setNewSearch] = useState('')

    const processSearch = (event) => {
        event.preventDefault();
        const search = newSearch.split(/[\s,]+/);
        setSearch(search);
    }

    return(
        <form onSubmit={processSearch} className='SearchBox'>
            <textarea value={newSearch} onChange={(e) => setNewSearch(e.target.value)}/>
            <br/>
            <button type='submit'>Search</button>
        </form>
    )
}

export default SearchBox