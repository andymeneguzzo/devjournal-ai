// Journaling page

import { useAuth } from "../context/AuthContext"
import {
    useEffect,
    useState
} from "react"

export default function Journal() {
    const { user } = useAuth()
    const [entries, setEntries] = useState([])
    const [text, setText] = useState("")
}