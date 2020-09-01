import { createMuiTheme } from '@material-ui/core/styles';

const theme = createMuiTheme({
    palette: {
        primary: {
          light: '#5393ff',
          main: '#2979ff',
          dark: '#1c54b2',
          contrastText: '#fff',
        },
        secondary: {
            light: '#f9f9f9',
            main: '#f0f0f0',
            dark: '#d9d9d9',
            contrastText: '#000',
        },
    },
  })

export default theme